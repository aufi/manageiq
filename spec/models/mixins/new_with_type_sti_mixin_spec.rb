require "spec_helper"

describe NewWithTypeStiMixin do
  context ".new" do
    it "without type" do
      expect(Host.new.class).to eq Host
      expect(ManageIQ::Providers::Redhat::InfraManager::Host.new.class).to eq ManageIQ::Providers::Redhat::InfraManager::Host
      expect(ManageIQ::Providers::Vmware::InfraManager::Host.new.class).to eq ManageIQ::Providers::Vmware::InfraManager::Host
      expect(ManageIQ::Providers::Vmware::InfraManager::HostEsx.new.class).to eq ManageIQ::Providers::Vmware::InfraManager::HostEsx
    end

    it "with type" do
      expect(Host.new(:type => "Host").class).to eq Host
      expect(Host.new(:type => "ManageIQ::Providers::Redhat::InfraManager::Host").class).to eq ManageIQ::Providers::Redhat::InfraManager::Host
      expect(Host.new(:type => "ManageIQ::Providers::Vmware::InfraManager::Host").class).to eq ManageIQ::Providers::Vmware::InfraManager::Host
      expect(Host.new(:type => "ManageIQ::Providers::Vmware::InfraManager::HostEsx").class).to eq ManageIQ::Providers::Vmware::InfraManager::HostEsx
      expect(ManageIQ::Providers::Vmware::InfraManager::Host.new(:type  => "ManageIQ::Providers::Vmware::InfraManager::HostEsx").class).to eq ManageIQ::Providers::Vmware::InfraManager::HostEsx

      expect(Host.new("type" => "Host").class).to eq Host
      expect(Host.new("type" => "ManageIQ::Providers::Redhat::InfraManager::Host").class).to eq ManageIQ::Providers::Redhat::InfraManager::Host
      expect(Host.new("type" => "ManageIQ::Providers::Vmware::InfraManager::Host").class).to eq ManageIQ::Providers::Vmware::InfraManager::Host
      expect(Host.new("type" => "ManageIQ::Providers::Vmware::InfraManager::HostEsx").class).to eq ManageIQ::Providers::Vmware::InfraManager::HostEsx
      expect(ManageIQ::Providers::Vmware::InfraManager::Host.new("type" => "ManageIQ::Providers::Vmware::InfraManager::HostEsx").class).to eq ManageIQ::Providers::Vmware::InfraManager::HostEsx
    end

    context "with invalid type" do
      it "that doesn't exist" do
        -> { Host.new(:type  => "Xxx") }.should raise_error
        -> { Host.new("type" => "Xxx") }.should raise_error
      end

      it "that isn't a subclass" do
        -> { Host.new(:type  => "ManageIQ::Providers::Vmware::InfraManager::Vm") }.should raise_error
        -> { Host.new("type" => "ManageIQ::Providers::Vmware::InfraManager::Vm") }.should raise_error

        -> { ManageIQ::Providers::Vmware::InfraManager::Host.new(:type  => "Host") }.should raise_error
        -> { ManageIQ::Providers::Vmware::InfraManager::Host.new("type" => "Host") }.should raise_error

        -> { ManageIQ::Providers::Vmware::InfraManager::Host.new(:type  => "ManageIQ::Providers::Redhat::InfraManager::Host") }.should raise_error
        -> { ManageIQ::Providers::Vmware::InfraManager::Host.new("type" => "ManageIQ::Providers::Redhat::InfraManager::Host") }.should raise_error
      end
    end
  end
end
