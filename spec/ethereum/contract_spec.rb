require 'spec_helper'

describe Ethereum do

  before(:all) do
    @client = Ethereum::IpcClient.new
    account_missing = @client.eth_accounts["result"].size == 0
    raise "You need to have at an account with 0.02 ether to run test" if account_missing
  end

  it "should build, deploy, use and kill simple contract" do
    path = "#{Dir.pwd}/spec/fixtures/Works.sol"
    @works = Ethereum::Contract.from_file(path, @client)
    @works.deploy_and_wait
    @works.transact_and_wait_set("some4key", "somethevalue")

    address = @works.deployment.contract_address
    abi = @works.abi
    @works_reloaded = Ethereum::Contract.from_blockchain("WorksReloaded", address, abi, @client)
    expect(@works_reloaded.call_get("some4key")).to eq "somethevalue"
    expect(@works.transact_and_wait_kill.mined?).to be true
  end

end
