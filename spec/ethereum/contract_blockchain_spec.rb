require 'spec_helper'

describe Ethereum do

  let(:client) { Ethereum::IpcClient.new }
  let(:path) { "#{Dir.pwd}/spec/fixtures/Works.sol" }

  it "should build, deploy, use and kill simple contract", slow: true do
    @works = Ethereum::Contract.from_file(path, client)
    contract_address = @works.deploy_and_wait
    tx_address = @works.transact_and_wait_set("some4key", "somethevalue").address
    expect(Ethereum::Transaction.from_blockchain(tx_address).mined?).to be true
    abi = @works.abi
    @works_reloaded = Ethereum::Contract.from_blockchain("WorksReloaded", contract_address, abi, client)
    expect(@works_reloaded.call_get("some4key")).to eq "somethevalue"
    expect(@works.transact_and_wait_kill.mined?).to be true
  end

end
