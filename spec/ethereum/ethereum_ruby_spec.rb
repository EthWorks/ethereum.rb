require 'spec_helper'

describe "Ethereum" do

  it 'has a version number' do
    expect(Ethereum::VERSION).to eq("1.6.0")
  end

end