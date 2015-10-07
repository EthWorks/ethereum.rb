require 'spec_helper'

describe Ethereum do
  it 'has a version number' do
    expect(Ethereum::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
