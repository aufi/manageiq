module ManageIQ::Providers::CloudManager::Provision::StateMachine
  def create_destination
    signal :determine_placement
  end

  def determine_placement
    availability_zone = placement
    options[:dest_availability_zone] = [availability_zone.try(:id), availability_zone.try(:name)]
    signal :prepare_volumes
  end

  def prepare_volumes
    # requested_volumes = miq_request.options[:volumes] || # signal :prepare_provision to skip this
    # TODO(maufart): data for testing, remove then
    requested_volumes = [{name: "m_vol_#{Time.now.to_i}", size: 1, source_type: 'volume', destination_type: 'volume'}]

    phase_context[:requested_volumes] = create_requested_volumes(requested_volumes)
    signal :poll_volumes_complete
  end

  def poll_volumes_complete
    status, status_message = do_volume_creation_check(phase_context[:requested_volumes])
    status_message = "completed prepare provision work queued" if status
    message = "Volume creation is #{status_message}"
    _log.info("#{message}")
    update_and_notify_parent(:message => message)
    if status
      # needed also in nova call - phase_context.delete(:requested_volumes)
      signal :prepare_provision
    else
      requeue_phase
    end
  end

  def start_clone_task
    update_and_notify_parent(:message => "Starting Clone of #{clone_direction}")
    # TODO(maufart): place following line elsewhere?
    phase_context[:clone_options][:block_device_mapping_v2] = phase_context[:requested_volumes] if phase_context[:requested_volumes]
    # binding.pry
    log_clone_options(phase_context[:clone_options])
    phase_context[:clone_task_ref] = start_clone(phase_context[:clone_options])
    phase_context.delete(:clone_options)
    signal :poll_clone_complete
  end

  def poll_clone_complete
    clone_status, status_message = do_clone_task_check(phase_context[:clone_task_ref])

    status_message = "completed; post provision work queued" if clone_status
    message = "Clone of #{clone_direction} is #{status_message}"
    _log.info("#{message}")
    update_and_notify_parent(:message => message)

    if clone_status
      clone_task_ref = phase_context.delete(:clone_task_ref)
      phase_context[:new_vm_ems_ref] = clone_task_ref
      EmsRefresh.queue_refresh(source.ext_management_system)
      signal :poll_destination_in_vmdb
    else
      requeue_phase
    end
  end

  def customize_destination
    message = "Customizing #{for_destination}"
    _log.info("#{message} #{for_destination}")
    update_and_notify_parent(:message => message)

    if floating_ip
      _log.info("Associating floating IP address [#{floating_ip.address}] to #{for_destination}")
      associate_floating_ip(floating_ip.address)
    end

    signal :post_create_destination
  end
end
