require 'spec_helper'

describe "Ethereum" do

  it 'has a version number' do
    expect(Ethereum::VERSION).to eq("1.5.18")
  end

end