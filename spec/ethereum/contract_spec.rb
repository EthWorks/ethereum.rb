require 'spec_helper'

describe Ethereum::Contract do

  let(:contract_path) { "#{Dir.pwd}/spec/fixtures/greeter.sol" }
  let(:client) { Ethereum::IpcClient.new }
  let(:address) { "0xaf83b6f1162062aa6711de633821f3e66b6fb3a5" }
  let(:eth_accounts_request) { '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' }
  let(:eth_accounts_result) { '{"jsonrpc":"2.0","result":["0x27dcb234fab8190e53e2d949d7b2c37411efb72e","0x3089630d06fd90ef48a0c43f000971587c1f3247"],"id":1}' }
  let(:eth_send_result) { '{"jsonrpc":"2.0", "result": "", "id": 1}' }
  let(:contract) { Ethereum::Contract.from_file(contract_path, client) }

  shared_examples "communicate with node" do
    it "communicate with node" do
      contract.at(address)
      expect(client).to receive(:send_single).once.with(eth_accounts_request).and_return(eth_accounts_result)
      expect(client).to receive(:send_single).once.with(eth_send_request).and_return(eth_send_result)
      subject
    end
  end

  context "transact" do
    let(:eth_send_request) { '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"to":"0xaf83b6f1162062aa6711de633821f3e66b6fb3a5","from":"0x27dcb234fab8190e53e2d949d7b2c37411efb72e","data":"0xcfae3217"}],"id":1}' }
    subject { contract.transact_greet }
    it_behaves_like "communicate with node"
  end

  context "transact and wait" do
    let(:eth_send_request) { '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"to":"0xaf83b6f1162062aa6711de633821f3e66b6fb3a5","from":"0x27dcb234fab8190e53e2d949d7b2c37411efb72e","data":"0xcfae3217"}],"id":1}' }
    let(:eth_get_transaction_request) { '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":[""],"id":1}' }
    let(:eth_get_transaction_result) { '{"jsonrpc":"2.0","result":{"blockHash":"0xc1e5032da79990789fb6933d31fb5670e66aec1e88fa98efbc1c9d4507c070ab","blockNumber":"0x56893","creates":null,"from":"0x27dcb234fab8190e53e2d949d7b2c37411efb72e","gas":"0xe57e0","gasPrice":"0x4a817c800","hash":"0x528b3c18433ea9b9089f0eef1f5be722934e629e441fa1af07f33531b20c22c9","input":"0x41c0e1b5","nonce":"0x25","publicKey":"0xccfdb8fdcf107fa9aa3fbaef7bc33c97685a7ab61f9cbef8e510fff848930b444e0ae2e66b27326b95cab0ff070c1db793f396c646ae2cb17ad539f41af23099","r":"0x07139d16062f86f003836a6b41ff2fba5c8988daa745c44cddeb807f7c5dee5e","raw":"0xf869258504a817c800830e57e0945b1141d29fad616d221fff559dcaa11bbb2ebcb7808441c0e1b52aa007139d16062f86f003836a6b41ff2fba5c8988daa745c44cddeb807f7c5dee5ea0415b0bdbc6bee69a8e6518abe914ae29a4f0a4a23f7aa9683f4fe5b16bafc0d9","s":"0x415b0bdbc6bee69a8e6518abe914ae29a4f0a4a23f7aa9683f4fe5b16bafc0d9","to":"0x5b1141d29fad616d221fff559dcaa11bbb2ebcb7","transactionIndex":"0x3","v":1,"value":"0x0"},"id":1}' }
    it "communicate with node" do
      contract.at(address)
      expect(client).to receive(:send_single).once.with(eth_accounts_request).and_return(eth_accounts_result)
      expect(client).to receive(:send_single).once.with(eth_send_request).and_return(eth_send_result)
      expect(client).to receive(:send_single).once.with(eth_get_transaction_request).and_return(eth_get_transaction_result)
      contract.transact_and_wait_greet
    end
  end
  context "call" do
    let(:eth_send_request) { '{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"0xaf83b6f1162062aa6711de633821f3e66b6fb3a5","from":"0x27dcb234fab8190e53e2d949d7b2c37411efb72e","data":"0xcfae3217"},"latest"],"id":1}' }
    subject { contract.call_greet }
    it_behaves_like "communicate with node"
  end

end
