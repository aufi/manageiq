require "spec_helper"
require_migration

describe UpdateTenantDivisibleOnExistingRows do
  let(:tenant_stub)  { migration_stub(:Tenant) }

  migration_context :up do
    it "updates nil values to true" do
      t_nil = tenant_stub.create!(:divisible => nil)
      expect(t_nil.divisible).to be_nil

      migrate

      t_nil.reload
      expect(t_nil.divisible).to be_true
    end

    it "leaves true and false values alone" do
      t_true  = tenant_stub.create!(:divisible => true)
      t_false = tenant_stub.create!(:divisible => false)

      expect(t_true.divisible).to be_true
      expect(t_false.divisible).to be_false

      migrate

      t_true.reload
      t_false.reload

      expect(t_true.divisible).to be_true
      expect(t_false.divisible).to be_false
    end
  end
end
