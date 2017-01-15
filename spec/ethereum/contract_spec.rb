require 'spec_helper'

describe Ethereum do

  let(:contract_path) { "#{Dir.pwd}/spec/fixtures/Works.sol" }
  let!(:client) { Ethereum::IpcClient.new }
  let(:eth_accounts_result) { '{"jsonrpc":"2.0","result":["0x27dcb234fab8190e53e2d949d7b2c37411efb72e","0x3089630d06fd90ef48a0c43f000971587c1f3247"],"id":1}' }
  let(:eth_accounts_request) { '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' }
  let(:eth_send_request) { '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"to":"0xaf83b6f1162062aa6711de633821f3e66b6fb3a5","from":"0x27dcb234fab8190e53e2d949d7b2c37411efb72e","data":"0xf71f7a256b6579000000000000000000000000000000000000000000000000000000000076616c7565000000000000000000000000000000000000000000000000000000"}],"id":1}' }
  let(:eth_send_result) { '{"jsonrpc":"2.0", "result": "0xe102f2988180d5f52218d2e1007647ef08b028509aa79264c695509d82339295", "id": 1}' }
  let(:abi) { [{"constant"=>true, "inputs"=>[{"name"=>"", "type"=>"bytes32"}], "name"=>"signatures", "outputs"=>[{"name"=>"", "type"=>"bytes32"}], "payable"=>false, "type"=>"function"}, {"constant"=>false, "inputs"=>[], "name"=>"kill", "outputs"=>[], "payable"=>false, "type"=>"function"}, {"constant"=>true, "inputs"=>[], "name"=>"owner", "outputs"=>[{"name"=>"", "type"=>"address"}], "payable"=>false, "type"=>"function"}, {"constant"=>true, "inputs"=>[{"name"=>"id", "type"=>"bytes32"}], "name"=>"get", "outputs"=>[{"name"=>"", "type"=>"bytes32"}], "payable"=>false, "type"=>"function"}, {"constant"=>false, "inputs"=>[{"name"=>"id", "type"=>"bytes32"}], "name"=>"unset", "outputs"=>[], "payable"=>false, "type"=>"function"}, {"constant"=>false, "inputs"=>[{"name"=>"id", "type"=>"bytes32"}, {"name"=>"sig", "type"=>"bytes32"}], "name"=>"set", "outputs"=>[], "payable"=>false, "type"=>"function"}, {"inputs"=>[], "payable"=>false, "type"=>"constructor"}] }
  let(:address) { "0xaf83b6f1162062aa6711de633821f3e66b6fb3a5" }

  it "should call json rpc methods", slow: true do
    works = Ethereum::Contract.from_file(contract_path, client)
    works.at(address)
    expect(client).to receive(:send_single).once.with(eth_accounts_request).and_return(eth_accounts_result)
    expect(client).to receive(:send_single).once.with(eth_send_request).and_return(eth_send_result)
    works.transact_set("key", "value")
  end

end
