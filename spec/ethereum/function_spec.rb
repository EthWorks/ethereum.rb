require 'spec_helper'

describe Ethereum::Function do

  it "calculates id" do
    expect(Ethereum::Function.calc_id("sam(bytes,bool,uint256[])")).to eq "a5643bf2"
  end

  context "calculates signature without synonyms" do
    let(:inputs_json1) { {"type" => "bytes", "name" => "nomatter"} }
    let(:inputs_json2) { {"type" => "bool", "name" => "nomatter"} }
    let(:inputs_json3) { {"type" => "uint256[]", "name" => "nomatter"} }
    let(:inputs) { [Ethereum::FunctionInput.new(inputs_json1), Ethereum::FunctionInput.new(inputs_json2), Ethereum::FunctionInput.new(inputs_json3)] }
    it "simple" do
      expect(Ethereum::Function.calc_signature("sam", inputs)).to eq "sam(bytes,bool,uint256[])"
    end
  end

  context "calculates signature with synonyms" do
    let(:inputs_json1) { {"type" => "int", "name" => "nomatter"} }
    let(:inputs_json2) { {"type" => "uint[]", "name" => "nomatter"} }
    let(:inputs_json3) { {"type" => "fixed", "name" => "nomatter"} }
    let(:inputs_json4) { {"type" => "ufixed", "name" => "nomatter"} }
    let(:inputs) { [Ethereum::FunctionInput.new(inputs_json1), Ethereum::FunctionInput.new(inputs_json2), Ethereum::FunctionInput.new(inputs_json3), Ethereum::FunctionInput.new(inputs_json4)] }
    it "simple" do
      expect(Ethereum::Function.calc_signature("sam", inputs)).to eq "sam(int256,uint256[],fixed128x128,ufixed128x128)"
    end
  end

end