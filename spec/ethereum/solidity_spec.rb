require 'spec_helper'

describe Ethereum do

  GREETER_BIN = '606060405234610000576040516102c13803806102c1833981016040528051015b5b60008054600160a060020a0319163360'

  MORTAL_BIN = '606060405234610000575b60008054600160a060020a03191633600160a060020a03161790555b5b609b8061003560003960'

  MORTAL_ABI = '[{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"}]'
  
  GREETER_ABI = '[{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"greet","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"inputs":[{"name":"_greeting","type":"string"}],"payable":false,"type":"constructor"}]'


  before(:all) do
    @contract_path = "#{Dir.pwd}/spec/fixtures/greeter.sol"
  end

  it "compiles contract" do
    contract = Ethereum::Solidity.new.compile(@contract_path)
    expect(contract["greeter"]["abi"].strip).to eq GREETER_ABI
    expect(contract["mortal"]["abi"].strip).to eq MORTAL_ABI
    expect(contract["greeter"]["bin"]).to start_with GREETER_BIN
    expect(contract["mortal"]["bin"]).to start_with MORTAL_BIN
  end

  it "raises ComplicationError if there is a compilation error" do
    expect { Ethereum::Solidity.new.compile("#{Dir.pwd}/spec/fixtures/ContractWithError.sol") }.to raise_error(Ethereum::CompilationError, /.*Error: Identifier not found or not unique.*/)
  end

  it "raises SystemCallError if can't run solc" do
    expect { Ethereum::Solidity.new('no_solc').compile(@contract_path) }.to raise_error(SystemCallError)
  end
  
end
