require 'spec_helper'

describe Ethereum::Formatter do

  let (:formatter) { Ethereum::Formatter.new }

  it "#to_wei" do
    expect(formatter.to_wei(1)).to eq 1000000000000000000
    expect(formatter.to_wei(nil)).to be_nil
  end

  it "#from_wei" do
    expect(formatter.from_wei(1000000000000000000)).to eq "1.0"
    expect(formatter.from_wei(nil)).to be_nil
  end
end
