require 'spec_helper'

describe Ethereum::Contract do

  let(:contract_path) { "#{Dir.pwd}/spec/fixtures/greeter.sol" }
  let(:client) { Ethereum::IpcClient.new }
  let(:address) { "0xaf83b6f1162062aa6711de633821f3e66b6fb3a5" }
  let(:eth_accounts_request) { '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' }
  let(:eth_accounts_result) { '{"jsonrpc":"2.0","result":["0x27dcb234fab8190e53e2d949d7b2c37411efb72e","0x3089630d06fd90ef48a0c43f000971587c1f3247"],"id":1}' }
  let(:eth_send_result) { '{"jsonrpc":"2.0", "result": "", "id": 1}' }

  shared_examples "communicate with node" do
    it "communicate with node" do
      contract.at(address)
      expect(client).to receive(:send_single).once.with(eth_accounts_request).and_return(eth_accounts_result)
      expect(client).to receive(:send_single).once.with(eth_send_request).and_return(eth_send_result)
      subject
    end
  end

  context "transact" do
    let(:contract) { Ethereum::Contract.from_file(contract_path, client) }
    let(:eth_send_request) { '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"to":"0xaf83b6f1162062aa6711de633821f3e66b6fb3a5","from":"0x27dcb234fab8190e53e2d949d7b2c37411efb72e","data":"0xcfae3217"}],"id":1}' }
    subject { contract.transact_greet }
    it_behaves_like "communicate with node"
  end

end
