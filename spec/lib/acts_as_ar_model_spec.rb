require "spec_helper"

describe ActsAsArModel do
  before(:each) do
    class TestClass1 < ActsAsArModel
      set_columns_hash(
        :str              => :string,
        :int              => :integer,
        :flt              => :float,
        :dt               => :datetime,
        :str_with_options => {:type => :string, :some_opt => 'opt_value'}
      )
    end

    # id is a default column included regardless if it's in the set_columns_hash
    @col_names_syms = [:str, :id, :int, :flt, :dt, :str_with_options]
    @col_names_strs = ["str", "id", "int", "flt", "dt", "str_with_options"]
  end

  after(:each) do
    Object.send(:remove_const, :TestClass1)
  end

  describe "subclass, TestClass1," do
    it(".base_class") { expect(TestClass1.base_class).to eq TestClass1 }
    it(".base_model") { expect(TestClass1.base_model).to eq TestClass1 }

    it { expect(TestClass1).to respond_to(:columns_hash) }
    it { expect(TestClass1).to respond_to(:columns) }
    it { expect(TestClass1).to respond_to(:column_names) }
    it { expect(TestClass1).to respond_to(:column_names_symbols) }

    it { expect(TestClass1).to respond_to(:virtual_columns) }

    it { expect(TestClass1).to respond_to(:aar_columns) }

    it { expect(TestClass1.columns_hash.values[0]).to be_kind_of(ActsAsArModelColumn) }
    it { expect(TestClass1.columns_hash.keys).to match_array(@col_names_strs) }
    it { expect(TestClass1.column_names).to match_array(@col_names_strs) }
    it { expect(TestClass1.column_names_symbols).to match_array(@col_names_syms) }

    it { expect(TestClass1.columns_hash["str_with_options"].options[:some_opt]).to eq 'opt_value' }

    describe "instance" do
      it { expect(TestClass1.new).to respond_to(:attributes) }
      it { expect(TestClass1.new).to respond_to(:str) }

      it "should allow attribute initialization" do
        t = TestClass1.new(:str => "test_value")
        expect(t.str).to eq "test_value"
      end

      it "should allow attribute access" do
        t = TestClass1.new
        expect(t.str).to be_nil

        t.str = "test_value"
        expect(t.str).to eq "test_value"
      end
    end

    describe "subclass, TestSubClass1," do
      before(:each) { class TestSubClass1 < TestClass1; end }
      after(:each)  { Object.send(:remove_const, :TestSubClass1) }

      it(".base_class") { expect(TestSubClass1.base_class).to eq TestClass1 }
      it(".base_model") { expect(TestSubClass1.base_model).to eq TestClass1 }
    end
  end

  describe "subclass, TestClass2," do
    before(:each) { class TestClass2 < ActsAsArModel; end }
    after(:each)  { Object.send(:remove_const, :TestClass2) }

    it(".base_class") { expect(TestClass2.base_class).to eq TestClass2 }
    it(".base_model") { expect(TestClass2.base_model).to eq TestClass2 }

    it { expect(TestClass2.columns_hash).to be_empty }
  end
end
