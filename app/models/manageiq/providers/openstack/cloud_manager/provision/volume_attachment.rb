module ManageIQ::Providers::Openstack::CloudManager::Provision::VolumeAttachment
  def create_requested_volumes(requested_volumes)
    volumes_attrs_list = []
    source.ext_management_system.with_provider_connection(service: "volume") do |service|
      requested_volumes.each do |volume_attrs|
        new_volume_id = service.volumes.create(volume_attrs).id
        new_volume_attrs = volume_attrs.clone
        new_volume_attrs[:uuid] = new_volume_id
        volumes_attrs_list << new_volume_attrs
      end
      volumes_attrs_list.first[:boot_index] = 0
    end
    volumes_attrs_list
  end

  def do_volume_creation_check(volumes_refs)
    source.ext_management_system.with_provider_connection(service: "volume") do |service|
      volumes_refs.each do |volume_attrs|
        status = service.volumes.get(volume_attrs[:uuid]).status
        return false, status unless status == "available"
      end
    end
    true
  end
end
