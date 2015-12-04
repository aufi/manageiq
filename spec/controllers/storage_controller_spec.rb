require "spec_helper"

describe StorageController do
  context "#button" do
    it "when VM Right Size Recommendations is pressed" do
      controller.instance_variable_set(:@_params, :pressed => "vm_right_size")
      controller.should_receive(:vm_right_size)
      controller.button
      expect(controller.send(:flash_errors?)).not_to be_true
    end

    it "when VM Migrate is pressed" do
      controller.instance_variable_set(:@_params, :pressed => "vm_migrate")
      controller.instance_variable_set(:@refresh_partial, "layouts/gtl")
      controller.should_receive(:prov_redirect).with("migrate")
      controller.should_receive(:render)
      controller.button
      expect(controller.send(:flash_errors?)).not_to be_true
    end

    it "when VM Retire is pressed" do
      controller.instance_variable_set(:@_params, :pressed => "vm_retire")
      controller.should_receive(:retirevms).once
      controller.button
      expect(controller.send(:flash_errors?)).not_to be_true
    end

    it "when VM Manage Policies is pressed" do
      controller.instance_variable_set(:@_params, :pressed => "vm_protect")
      controller.should_receive(:assign_policies).with(VmOrTemplate)
      controller.button
      expect(controller.send(:flash_errors?)).not_to be_true
    end

    it "when MiqTemplate Manage Policies is pressed" do
      controller.instance_variable_set(:@_params, {:pressed => "miq_template_protect"})
      controller.should_receive(:assign_policies).with(VmOrTemplate)
      controller.button
      expect(controller.send(:flash_errors?)).not_to be_true
    end

    it "when VM Tag is pressed" do
      controller.instance_variable_set(:@_params, :pressed => "vm_tag")
      controller.should_receive(:tag).with(VmOrTemplate)
      controller.button
      expect(controller.send(:flash_errors?)).not_to be_true
    end

    it "when MiqTemplate Tag is pressed" do
      controller.instance_variable_set(:@_params, :pressed => "miq_template_tag")
      controller.should_receive(:tag).with(VmOrTemplate)
      controller.button
      expect(controller.send(:flash_errors?)).not_to be_true
    end

    it "when Host Analyze then Check Compliance is pressed" do
      controller.instance_variable_set(:@_params, :pressed => "host_analyze_check_compliance")
      controller.stub(:show)
      controller.should_receive(:analyze_check_compliance_hosts)
      controller.should_receive(:render)
      controller.button
      expect(controller.send(:flash_errors?)).not_to be_true
    end

    {"host_standby"  => "Enter Standby Mode",
     "host_shutdown" => "Shut Down",
     "host_reboot"   => "Restart",
     "host_start"    => "Power On",
     "host_stop"     => "Power Off",
     "host_reset"    => "Reset"
    }.each do |button, description|
      it "when Host #{description} button is pressed" do
        login_as FactoryGirl.create(:user, :features => button)

        host = FactoryGirl.create(:host)
        controller.instance_variable_set(:@_params, :pressed => button, :miq_grid_checks => "#{host.id}")
        controller.instance_variable_set(:@lastaction, "show_list")
        controller.stub(:show_list)
        controller.should_receive(:render)
        controller.button
        flash_messages = assigns(:flash_array)
        expect(flash_messages.first[:message]).to include("successfully initiated")
        expect(flash_messages.first[:level]).to eq :success
      end
    end
  end
end
