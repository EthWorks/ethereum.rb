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

  context "#valid_address?" do
    it "with a null address" do
      expect(formatter.valid_address?("0x0000000000000000000000000000000000000000")).to eq false
    end

    it "with an address of 40 hexadecimal characters" do
      expect(formatter.valid_address?("0x9C11541DD6f927e9A8eeEe7D9d205c1061C88aB8")).to eq true
    end

    it "with an address of less than 40 hexadecimal characters" do
      expect(formatter.valid_address?("0x9C11541DD6f927e9A8eeEe7D9d205c1061C88aB")).to eq false
    end

    it "with an address of more than 40 hexadecimal characters" do
      expect(formatter.valid_address?("0x9C11541DD6f927e9A8eeEe7D9d205c1061C88aB81")).to eq false
    end

    it "with an address of 40 characters (but non-hexadecimal characters included at the end)" do
      expect(formatter.valid_address?("0x9C11541DD6f927e9A8eeEe7D9d205c1061C88aB*")).to eq false
    end

    it "with an address of 40 characters (but non-hexadecimal characters included at the middle)" do
      expect(formatter.valid_address?("0x9C11541DD6f927e9A8*eEe7D9d205c1061C88aB8")).to eq false
    end
  end
end
