require "spec_helper"

describe ManageIQ::Providers::Microsoft::InfraManager do
  it ".ems_type" do
    expect(described_class.ems_type).to eq 'scvmm'
  end

  it ".description" do
    expect(described_class.description).to eq 'Microsoft System Center VMM'
  end

  it ".auth_url handles ipv6" do
    expect(described_class.auth_url("::1")).to eq "http://[::1]:5985/wsman"
  end

  context "#connect with ssl" do
    before do
      @e = FactoryGirl.create(:ems_microsoft, :hostname => "host", :security_protocol => "ssl", :ipaddress => "127.0.0.1")
      @e.authentications << FactoryGirl.create(:authentication, :userid => "user", :password => "pass")
    end

    it "defaults" do
      described_class.should_receive(:raw_connect).with do |url, protocol, creds|
        expect(url).to match(/host/)
        expect(protocol).to be == "ssl"
        expect(creds[:user]).to be == "user"
        expect(creds[:pass]).to be == "pass"
      end

      @e.connect
    end

    it "accepts overrides" do
      described_class.should_receive(:raw_connect).with do |url, protocol, creds|
        expect(url).to match(/host2/)
        expect(protocol).to be == "ssl"
        expect(creds[:user]).to be == "user2"
        expect(creds[:pass]).to be == "pass2"
      end

      @e.connect(:user => "user2", :pass => "pass2", :hostname => "host2")
    end
  end

  context "#connect with kerberos" do
    before do
      @e = FactoryGirl.create(:ems_microsoft, :hostname => "host", :security_protocol => "kerberos", :realm => "pretendrealm", :ipaddress => "127.0.0.1")
      @e.authentications << FactoryGirl.create(:authentication, :userid => "user", :password => "pass")
    end

    it "defaults" do
      described_class.should_receive(:raw_connect).with do |url, protocol, creds|
        expect(url).to match(/host/)
        expect(protocol).to be == "kerberos"
        expect(creds[:user]).to be == "user"
        expect(creds[:pass]).to be == "pass"
        expect(creds[:realm]).to be == "pretendrealm"
      end

      @e.connect
    end

    it "accepts overrides" do
      described_class.should_receive(:raw_connect).with do |url, protocol, creds|
        expect(url).to match(/host2/)
        expect(protocol).to be == "kerberos"
        expect(creds[:user]).to be == "user2"
        expect(creds[:pass]).to be == "pass2"
        expect(creds[:realm]).to be == "pretendrealm"
      end

      @e.connect(:user => "user2", :pass => "pass2", :hostname => "host2")
    end
  end
end
