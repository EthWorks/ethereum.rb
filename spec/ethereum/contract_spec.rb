require 'spec_helper'

describe Ethereum do

  before(:all) do
    @client = Ethereum::HttpClient.new("http://localhost:8545", true)
    account_missing = @client.eth_accounts["result"].size == 0
    raise "You need to have at an account with 0.02 ether to run test" if account_missing
  end

  it "should build, deploy, use and kill contract" do
    @init = Ethereum::Initializer.new("#{Dir.pwd}/spec/fixtures/Works.sol", @client)
    @init.build_all
    @works = Works.new
    @works.deploy_and_wait
    @works.transact_and_wait_set("some4key", "somethevalue")
    expect(@works.call_get("some4key")).to eq "somethevalue"
    expect(@works.transact_and_wait_kill.mined?).to be true
  end

end
