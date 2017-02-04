require 'spec_helper'

describe Ethereum::Abi do

  let (:abi) { [{"constant"=>false,"inputs"=>[],"name"=>"kill","outputs"=>[],"payable"=>false,"type"=>"function"},{"constant"=>true,"inputs"=>[],"name"=>"greet","outputs"=>[{"name"=>"","type"=>"string"}],"payable"=>false,"type"=>"function"},{"inputs"=>[{"name"=>"_greeting","type"=>"string"}],"payable"=>false,"type"=>"constructor"}] }
  let (:empty_abi) { [] }
  it "parses abi" do
    constructor_inputs, functions, events = Ethereum::Abi::parse_abi(abi)
    expect(functions[0].name).to eq "kill"
    expect(functions[1].outputs[0].type).to eq "string"
    expect(constructor_inputs[0].name).to eq "_greeting"
    expect(constructor_inputs[0].type).to eq "string"
  end

  it "parses empty abi" do
    constructor_inputs, functions, events = Ethereum::Abi::parse_abi(empty_abi) 
    expect(functions).to eq []
    expect(constructor_inputs).to eq []
  end

  it "parse type" do
    expect(Ethereum::Abi::parse_type("bool")).to eq ["bool", nil]
    expect(Ethereum::Abi::parse_type("uint32")).to eq ["uint", "32"]
    expect(Ethereum::Abi::parse_type("bytes32")).to eq ["bytes", "32"]
    expect(Ethereum::Abi::parse_type("fixed128x128")).to eq ["fixed", "128x128"]
  end

  it "parse array type" do
    expect(Ethereum::Abi::parse_array_type("int")).to eq [false, nil, nil]
    expect(Ethereum::Abi::parse_array_type("int[2]")).to eq [true, 2, "int"]
    expect(Ethereum::Abi::parse_array_type("int[]")).to eq [true, nil, "int"]
    expect(Ethereum::Abi::parse_array_type("int[2][]")).to eq [true, nil, "int[2]"]
    expect(Ethereum::Abi::parse_array_type("int[2][3]")).to eq [true, 3, "int[2]"]
  end

end