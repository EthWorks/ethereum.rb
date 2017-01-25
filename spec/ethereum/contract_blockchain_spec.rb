require 'spec_helper'

describe Ethereum do

  let(:client) { Ethereum::IpcClient.new }
  let(:path) { "#{Dir.pwd}/spec/fixtures/TestContract.sol" }

  it "should build, deploy, call methods, receive events and kill contract", slow: true do
    @works = Ethereum::Contract.from_file(path, client)
    expect(@works.estimate).to be > 100
    contract_address = @works.deploy_and_wait

    filter_id = @works.new_filter.changed address: contract_address, topics: []
    tx_address = @works.transact_and_wait.set("some4key", "somethevalue").address
    sleep 3
    expect(@works.get_filter_changes.changed(filter_id)[0][:transactionHash]).to eq tx_address
    expect(@works.get_filter_logs.changed(filter_id)[0][:transactionHash]).to eq tx_address
    expect(Ethereum::Transaction.from_blockchain(tx_address).mined?).to be true

    @works_reloaded = Ethereum::Contract.from_blockchain("WorksReloaded", contract_address, @works.abi, client)
    expect(@works_reloaded.call.get("some4key")).to eq ["somethevalue", "żółć"]
    expect(@works.transact_and_wait.kill.mined?).to be true
  end

end
