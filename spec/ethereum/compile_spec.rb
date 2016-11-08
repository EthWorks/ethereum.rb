require 'spec_helper'

describe Ethereum do

  before(:all) do
    @client = Ethereum::HttpClient.new("http://localhost:8545")
  end
  
  it "should compile contract" do
    @init = Ethereum::Initializer.new("#{Dir.pwd}/spec/fixtures/SimpleNameRegistry.sol", @client)
    @init.build_all
    @simple_name_registry = SimpleNameRegistry.new
    @simple_name_registry.deploy_and_wait(60)
  end

end
