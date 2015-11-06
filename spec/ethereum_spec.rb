require 'spec_helper'

describe Ethereum do

  before(:all) do
    @client = Ethereum::HttpClient.new("172.16.135.102", "8545")
    @formatter = Ethereum::Formatter.new
  end

  describe "Ethereum Version" do
    it 'has a version number' do
      expect(Ethereum::VERSION).to eq("0.4.90")
    end
  end
  
  describe "Deployment" do
    it "should deploy a contract with parameters" do
      @init = Ethereum::Initializer.new("#{ENV['PWD']}/spec/fixtures/ContractWithParams.sol", @client)
      @init.build_all
      @contract_with_params = ContractWithParams.new
      @coinbase = @contract_with_params.connection.coinbase["result"]
      @contract_with_params.deploy_and_wait(60, @coinbase)
      address = @contract_with_params.call_get_setting__
      expect(address).to eq(@coinbase)
    end

  end


  describe "Basic contract testing" do

    before(:all) do
      @init = Ethereum::Initializer.new("#{ENV['PWD']}/spec/fixtures/SimpleNameRegistry.sol", @client)
      @init.build_all
      @simple_name_registry = SimpleNameRegistry.new
      @simple_name_registry.deploy_and_wait(60)
    end

    it "should perform a contract transaction, wait for its completion, return an Ethereum::Transaction object" do
      tx = @simple_name_registry.transact_and_wait_register("0x5b6cb65d40b0e27fab87a2180abcab22174a2d45", "minter.contract.dgx")
      expect(tx.class).to be(Ethereum::Transaction)
    end

    it "should test a call_(Ethereum Contract Function)" do
      expect(true).to be(true)
    end

  end

end
