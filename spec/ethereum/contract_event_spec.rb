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
      expect(contract.nf_changed address: "70783C3CFaf354F425D85c1E8a5EfE4586C64b5D").to eq 2 
    end
  end

end
