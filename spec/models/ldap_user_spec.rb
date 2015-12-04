require "spec_helper"

describe LdapUser do
  context "with a small envs" do
    before(:each) do
      @task = FactoryGirl.create(:miq_task)
    end

    it "Assignment" do
      lm = FactoryGirl.create(:ldap_user, :dn => "manager")
      lu = FactoryGirl.create(:ldap_user, :dn => "employee")

      lm.direct_reports << lu

      expect(lm.direct_reports).to have(1).thing
      expect(lm.managers).to have(0).thing

      expect(lu.managers).to have(1).thing
      expect(lu.direct_reports).to have(0).thing
    end
  end
end
