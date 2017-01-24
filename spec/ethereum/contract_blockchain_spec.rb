require 'spec_helper'

describe Ethereum do

  let(:client) { Ethereum::IpcClient.new }
  let(:path) { "#{Dir.pwd}/spec/fixtures/TestContract.sol" }

  it "should build, deploy, use and kill simple contract", slow: true do
    @works = Ethereum::Contract.from_file(path, client)
    # expect(@works.estimate()).to be > 100
    # contract_address = @works.deploy_and_wait
    @works.address = "0x70783C3CFaf354F425D85c1E8a5EfE4586C64b5D"
    filter_id = @works.nf_changed address: "70783C3CFaf354F425D85c1E8a5EfE4586C64b5D", topics: []
    puts "filter_id: #{filter_id}"
    # tx_address = @works.transact_and_wait_set("some4key", "somethevalue").address
    # puts @works.gfl_changed filter_id
    # expect(Ethereum::Transaction.from_blockchain(tx_address).mined?).to be true
    # abi = @works.abi
    # @works_reloaded = Ethereum::Contract.from_blockchain("WorksReloaded", contract_address, abi, client)
    # expect(@works_reloaded.call_get("some4key")).to eq ["somethevalue", "żółć"]
    # expect(@works.transact_and_wait_kill.mined?).to be true
  end

end
