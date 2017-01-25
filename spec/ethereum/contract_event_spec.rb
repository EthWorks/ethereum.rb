require 'spec_helper'

describe Ethereum::Contract do

  let(:client) { Ethereum::IpcClient.new }
  let(:address) { "0xaf83b6f1162062aa6711de633821f3e66b6fb3a5" }
  let(:path) { "#{Dir.pwd}/spec/fixtures/TestContract.sol" }
  let(:eth_accounts_request) { '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' }
  let(:eth_accounts_result) { '{"jsonrpc":"2.0","result":["0x27dcb234fab8190e53e2d949d7b2c37411efb72e"],"id":1}' }

  before (:each) do
    expect(client).to receive(:send_single).at_least(1).with(eth_accounts_request).and_return(eth_accounts_result)
  end

  context "create filter" do
    let(:eth_send_request) { '{"jsonrpc":"2.0","method":"eth_newFilter","params":[{"topics":["0x0d3a6aeecf5d29a90d2c145270bd1b2554069d03e76c09a660b27ccd165c2c42"],"fromBlock":"0x0","toBlock":"latest","address":"0x70783C3CFaf354F425D85c1E8a5EfE4586C64b5D"}],"id":1}' }
    let(:eth_send_result) { '{"jsonrpc":"2.0","result":"0x2","id":1}' }
    let(:contract) { Ethereum::Contract.from_file(path, client) }
    it "succeed" do
      expect(client).to receive(:send_single).once.with(eth_send_request).and_return(eth_send_result)
      expect(contract.new_filter.changed address: "70783C3CFaf354F425D85c1E8a5EfE4586C64b5D").to eq 2 
    end
  end

  context "get filter logs" do
    let(:eth_send_request) { '{"jsonrpc":"2.0","method":"eth_getFilterLogs","params":["0x7"],"id":1}' }
    let(:eth_send_result) { '{"jsonrpc":"2.0","result":[{"address":"0x49ada70abe41b2890e4162ba1e946c60cb81f8ec","blockHash":"0x37e986c8ddd0060bfdabccd01897478b00cce8a20294ec9217b7a556125f1773","blockNumber":"0x644be","data":"0x","logIndex":"0x0","topics":["0x0d3a6aeecf5d29a90d2c145270bd1b2554069d03e76c09a660b27ccd165c2c42"],"transactionHash":"0x186833b9d97fcf36b9fa5b90e616b0a5b78b9cb9a31c646977deeecd31a5b207","transactionIndex":"0x0","transactionLogIndex":"0x0","type":"mined"}],"id":1}' }
    let (:expected) { {blockHash: "0x37e986c8ddd0060bfdabccd01897478b00cce8a20294ec9217b7a556125f1773", blockNumber: 410814, transactionHash: "0x186833b9d97fcf36b9fa5b90e616b0a5b78b9cb9a31c646977deeecd31a5b207"} }
    let(:contract) { Ethereum::Contract.from_file(path, client) }
    it "succeed" do
      expect(client).to receive(:send_single).once.with(eth_send_request).and_return(eth_send_result)
      expect(contract.get_filter_logs.changed(7)[0]).to include expected
    end
  end

  context "get filter changes" do
    let(:eth_send_request) { '{"jsonrpc":"2.0","method":"eth_getFilterChanges","params":["0x7"],"id":1}' }
    let(:eth_send_result) { '{"jsonrpc":"2.0","result":[{"address":"0x49ada70abe41b2890e4162ba1e946c60cb81f8ec","blockHash":"0x37e986c8ddd0060bfdabccd01897478b00cce8a20294ec9217b7a556125f1773","blockNumber":"0x644be","data":"0x","logIndex":"0x0","topics":["0x0d3a6aeecf5d29a90d2c145270bd1b2554069d03e76c09a660b27ccd165c2c42"],"transactionHash":"0x186833b9d97fcf36b9fa5b90e616b0a5b78b9cb9a31c646977deeecd31a5b207","transactionIndex":"0x0","transactionLogIndex":"0x0","type":"mined"}],"id":1}' }
    let (:expected) { {blockHash: "0x37e986c8ddd0060bfdabccd01897478b00cce8a20294ec9217b7a556125f1773", blockNumber: 410814, transactionHash: "0x186833b9d97fcf36b9fa5b90e616b0a5b78b9cb9a31c646977deeecd31a5b207"} }
    let(:contract) { Ethereum::Contract.from_file(path, client) }
    it "succeed" do
      expect(client).to receive(:send_single).once.with(eth_send_request).and_return(eth_send_result)
      expect(contract.get_filter_changes.changed(7)[0]).to include expected
    end
  end
end
