require 'spec_helper'

describe Ethereum::Solidity do
  let (:greeter_bin) { '6080604052348015610010576000' }
  let (:mortal_bin) { '6080604052348015600f57600080' }
  let (:mortal_abi) { '[{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}]' }
  let (:greeter_abi) { '[{"inputs":[{"internalType":"string","name":"_greeting","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"constant":true,"inputs":[],"name":"greet","outputs":[{"internalType":"string","name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}]' }
  let (:contract_path) { "#{Dir.pwd}/spec/fixtures/greeter.sol" }
  let (:compiler_instance) { Ethereum::Solidity.new }
  let (:subject) { compiler_instance.compile(contract_path) }

  it "compiles contract" do
    expect(subject["greeter"]["abi"].strip).to eq greeter_abi
    expect(subject["mortal"]["abi"].strip).to eq mortal_abi
    expect(subject["greeter"]["bin"]).to start_with greeter_bin
    expect(subject["mortal"]["bin"]).to start_with mortal_bin
  end

  context "compilation error" do
    let (:contract_path) { "#{Dir.pwd}/spec/fixtures/ContractWithError.sol" }
    it { expect{ subject }.to raise_error(Ethereum::CompilationError, /.*Error: Identifier not found or not unique.*/) }
  end

  context "compilator not installed" do
    let (:compiler_instance) { Ethereum::Solidity.new("no solc") }
    it { expect{ subject }.to raise_error(SystemCallError) }
  end
end
