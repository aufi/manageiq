require "spec_helper"

describe ManageIQ::Providers::Azure::CloudManager::OrchestrationStack::Status do
  it 'parses Succeeded' do
    status = described_class.new('Succeeded', '')
    expect(status.completed?).to be_true
    expect(status.succeeded?).to be_true
    expect(status.failed?).to be_false
    expect(status.deleted?).to be_false
    expect(status.rolled_back?).to be_false
    expect(status.normalized_status).to eq ['create_complete', '']
  end

  it 'parses Failed' do
    status = described_class.new('Failed', nil)
    expect(status.completed?).to be_true
    expect(status.succeeded?).to be_false
    expect(status.failed?).to be_true
    expect(status.deleted?).to be_false
    expect(status.rolled_back?).to be_false
    expect(status.normalized_status).to eq ['failed', 'Stack creation failed']
  end

  it 'parses Deleted' do
    status = described_class.new('Deleted', nil)
    expect(status.completed?).to be_true
    expect(status.succeeded?).to be_false
    expect(status.failed?).to be_false
    expect(status.deleted?).to be_true
    expect(status.rolled_back?).to be_false
    expect(status.normalized_status).to eq ['delete_complete', 'Stack was deleted']
  end

  it 'parses Canceled' do
    status = described_class.new('Canceled', nil)
    expect(status.completed?).to be_true
    expect(status.succeeded?).to be_false
    expect(status.canceled?).to be_true
    expect(status.deleted?).to be_false
    expect(status.rolled_back?).to be_false
    expect(status.normalized_status).to eq ['create_canceled', 'Stack creation was canceled']
  end

  it 'parses transient status' do
    status = described_class.new('CREATING', nil)
    expect(status.completed?).to be_false
    expect(status.succeeded?).to be_false
    expect(status.failed?).to be_false
    expect(status.deleted?).to be_false
    expect(status.rolled_back?).to be_false
    expect(status.normalized_status).to eq %w(transient CREATING)
  end
end
