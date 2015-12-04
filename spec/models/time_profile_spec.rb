require "spec_helper"

describe TimeProfile do
  before(:each) do
    @server = EvmSpecHelper.local_miq_server
    @ems    = FactoryGirl.create(:ems_vmware, :zone => @server.zone)
    EvmSpecHelper.clear_caches
  end

  it "will default to the correct profile values" do
    t = TimeProfile.new
    expect(t.days).to eq TimeProfile::ALL_DAYS
    expect(t.hours).to eq TimeProfile::ALL_HOURS
    expect(t.tz).to be_nil
  end

  context "will seed the database" do
    before(:each) do
      TimeProfile.seed
    end

    it do
      t = TimeProfile.first
      expect(t.days).to eq TimeProfile::ALL_DAYS
      expect(t.hours).to eq TimeProfile::ALL_HOURS
      expect(t.tz).to eq TimeProfile::DEFAULT_TZ
      expect(t.entire_tz?).to be_true
    end

    it "but not reseed when called twice" do
      TimeProfile.seed
      expect(TimeProfile.count).to eq 1
      t = TimeProfile.first
      expect(t.days).to eq TimeProfile::ALL_DAYS
      expect(t.hours).to eq TimeProfile::ALL_HOURS
      expect(t.tz).to eq TimeProfile::DEFAULT_TZ
      expect(t.entire_tz?).to be_true
    end
  end

  it "will return the correct values for tz_or_default" do
    t = TimeProfile.new
    expect(t.tz_or_default).to eq TimeProfile::DEFAULT_TZ
    expect(t.tz_or_default("Hawaii")).to eq "Hawaii"

    t.tz = "Hawaii"
    expect(t.tz).to eq "Hawaii"
    expect(t.tz_or_default).to eq "Hawaii"
    expect(t.tz_or_default("Alaska")).to eq "Hawaii"
  end

  it "will not rollup daily performances on create if rollups are disabled" do
    FactoryGirl.create(:time_profile)
    assert_nothing_queued
  end

  context "with an existing time profile with rollups disabled" do
    before(:each) do
      @tp = FactoryGirl.create(:time_profile)
      MiqQueue.delete_all
    end

    it "will not rollup daily performances if any changes are made" do
      @tp.update_attribute(:description, "New Description")
      assert_nothing_queued

      @tp.update_attribute(:days, [1, 2])
      assert_nothing_queued
    end

    it "will rollup daily performances if rollups are enabled" do
      @tp.update_attribute(:rollup_daily_metrics, true)
      assert_rebuild_daily_queued
    end
  end

  it "will rollup daily performances on create if rollups are enabled" do
    @tp = FactoryGirl.create(:time_profile_with_rollup)
    assert_rebuild_daily_queued
  end

  context "with an existing time profile with rollups enabled" do
    before(:each) do
      @tp = FactoryGirl.create(:time_profile_with_rollup)
      MiqQueue.delete_all
    end

    it "will not rollup daily performances if non-profile changes are made" do
      @tp.update_attribute(:description, "New Description")
      assert_nothing_queued
    end

    it "will rollup daily performances if profile changes are made" do
      @tp.update_attribute(:days, [1, 2])
      assert_rebuild_daily_queued
    end

    it "will not rollup daily performances if rollups are disabled" do
      @tp.update_attribute(:rollup_daily_metrics, false)
      assert_destroy_queued
    end
  end

  context "profiles_for_user" do
    before(:each) do
      TimeProfile.seed
    end

    it "gets time profiles for user and global default timeprofile" do
      tp = TimeProfile.find_by_description(TimeProfile::DEFAULT_TZ)
      tp.profile_type = "global"
      tp.save
      FactoryGirl.create(:time_profile,
                         :description          => "test1",
                         :profile_type         => "user",
                         :profile_key          => "some_user",
                         :rollup_daily_metrics => true)

      FactoryGirl.create(:time_profile,
                         :description          => "test2",
                         :profile_type         => "user",
                         :profile_key          => "foo",
                         :rollup_daily_metrics => true)
      tp = TimeProfile.profiles_for_user("foo", MiqRegion.my_region_number)
      expect(tp.count).to eq 2
    end
  end

  context "profile_for_user_tz" do
    before(:each) do
      TimeProfile.seed
    end

    it "gets time profiles that matches user's tz and marked for daily Rollup" do
      FactoryGirl.create(:time_profile,
                         :description          => "test1",
                         :profile_type         => "user",
                         :profile_key          => "some_user",
                         :tz                   => "other_tz",
                         :rollup_daily_metrics => true)

      FactoryGirl.create(:time_profile,
                         :description          => "test2",
                         :profile_type         => "user",
                         :profile_key          => "foo",
                         :tz                   => "foo_tz",
                         :rollup_daily_metrics => true)
      tp = TimeProfile.profile_for_user_tz("foo", "foo_tz")
      expect(tp.description).to eq "test2"
    end
  end

  def assert_rebuild_daily_queued
    q_all = MiqQueue.all
    expect(q_all.length).to eq 1
    expect(q_all[0].class_name).to eq "TimeProfile"
    expect(q_all[0].instance_id).to eq @tp.id
    expect(q_all[0].method_name).to eq "rebuild_daily_metrics"
  end

  def assert_destroy_queued
    q_all = MiqQueue.all
    expect(q_all.length).to eq 1
    expect(q_all[0].class_name).to eq "TimeProfile"
    expect(q_all[0].instance_id).to eq @tp.id
    expect(q_all[0].method_name).to eq "destroy_metric_rollups"
  end

  def assert_nothing_queued
    expect(MiqQueue.count).to eq 0
  end
end
