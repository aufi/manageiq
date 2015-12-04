require "spec_helper"

describe MiqTemplate do
  it ".corresponding_model" do
    expect(described_class.corresponding_model).to eq Vm
    expect(ManageIQ::Providers::Vmware::InfraManager::Template.corresponding_model).to eq ManageIQ::Providers::Vmware::InfraManager::Vm
    expect(ManageIQ::Providers::Redhat::InfraManager::Template.corresponding_model).to eq ManageIQ::Providers::Redhat::InfraManager::Vm
  end

  it ".corresponding_vm_model" do
    expect(described_class.corresponding_vm_model).to eq Vm
    expect(ManageIQ::Providers::Vmware::InfraManager::Template.corresponding_vm_model).to eq ManageIQ::Providers::Vmware::InfraManager::Vm
    expect(ManageIQ::Providers::Redhat::InfraManager::Template.corresponding_vm_model).to eq ManageIQ::Providers::Redhat::InfraManager::Vm
  end

  context "#template=" do
    before(:each) { @template = FactoryGirl.create(:template_vmware) }

    it "true" do
      @template.update_attribute(:template, true)
      expect(@template.type).to eq "ManageIQ::Providers::Vmware::InfraManager::Template"
      expect(@template.template).to eq true
      expect(@template.state).to eq "never"
      -> { @template.reload }.should_not raise_error
      -> { ManageIQ::Providers::Vmware::InfraManager::Vm.find(@template.id) }.should raise_error ActiveRecord::RecordNotFound
    end

    it "false" do
      @template.update_attribute(:template, false)
      expect(@template.type).to eq "ManageIQ::Providers::Vmware::InfraManager::Vm"
      expect(@template.template).to eq false
      expect(@template.state).to eq "unknown"
      -> { @template.reload }.should raise_error ActiveRecord::RecordNotFound
      -> { ManageIQ::Providers::Vmware::InfraManager::Vm.find(@template.id) }.should_not raise_error
    end
  end

  it ".supports_kickstart_provisioning?" do
    expect(ManageIQ::Providers::Amazon::CloudManager::Template.supports_kickstart_provisioning?).to be_false
    expect(ManageIQ::Providers::Redhat::InfraManager::Template.supports_kickstart_provisioning?).to be_true
    expect(ManageIQ::Providers::Vmware::InfraManager::Template.supports_kickstart_provisioning?).to be_false
  end

  it "#supports_kickstart_provisioning?" do
    expect(ManageIQ::Providers::Amazon::CloudManager::Template.new.supports_kickstart_provisioning?).to be_false
    expect(ManageIQ::Providers::Redhat::InfraManager::Template.new.supports_kickstart_provisioning?).to be_true
    expect(ManageIQ::Providers::Vmware::InfraManager::Template.new.supports_kickstart_provisioning?).to be_false
  end
end
