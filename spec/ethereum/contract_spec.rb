require 'spec_helper'

describe Ethereum do

  before(:all) do
    @client = Ethereum::HttpClient.new("http://localhost:8545", true)
  end

  it "should build, deploy, use and kill contract" do
    @init = Ethereum::Initializer.new("#{Dir.pwd}/spec/fixtures/Works.sol", @client)
    @init.build_all
    @works = Works.new
    @works.set_gas 53000
    @works.deploy_and_wait
    @works.transact_and_wait_set("some4key", "somethevalue")
    expect(@works.call_get("some4key")).to eq "somethevalue"
    expect(@works.transact_and_wait_kill.mined?).to be true
  end

end
