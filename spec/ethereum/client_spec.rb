require 'spec_helper'

describe Ethereum::Client do

    let (:client) { Ethereum::Client.new }

    describe '.encode_params' do
      let (:params) { [true, false, 0, 12345, '0x7d84abf0f241b10927b567bd636d95fa9f66ae34', '0x4d5e07d4057dd0c3849c2295d20ee1778fc29d69150e8d75a07207347dce17fa', '0x7d84abf0f241b10927b567bd636d95fa9f66ae34'] }
      let (:expected) { [true, false, '0x0', '0x3039', '0x7d84abf0f241b10927b567bd636d95fa9f66ae34', '0x4d5e07d4057dd0c3849c2295d20ee1778fc29d69150e8d75a07207347dce17fa', '0x7d84abf0f241b10927b567bd636d95fa9f66ae34'] }
      subject { client.encode_params(params) }
      it { is_expected.to eq expected}
    end

    shared_examples "json rpc method" do |request|
      let (:response) { '{"id":1, "jsonrpc":"2.0", "result": ""}' }
      it "is called" do
        expect(client).to receive(:send_single).once.with(request.to_json).and_return(response)
        subject
      end
    end

    describe ".web3_client_version" do
      subject { client.web3_client_version }
      it_behaves_like "json rpc method", {"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}
    end

    describe ".net_version" do
      subject { client.net_version }
      it_behaves_like "json rpc method", {"jsonrpc":"2.0","method":"net_version","params":[],"id":1}
    end

    describe ".eth_protocol_version" do
      subject { client.eth_protocol_version }
      it_behaves_like "json rpc method", {"jsonrpc":"2.0","method":"eth_protocolVersion","params":[],"id":1}
    end

    describe ".shh_new_identity" do
      subject { client.shh_new_identity }
      it_behaves_like "json rpc method", {"jsonrpc":"2.0","method":"shh_newIdentity","params":[],"id":1}
    end

    describe ".eth_call" do
      subject { client.eth_call(to: "0x407d73d8a49eeb85d32cf465507dd71d507100c1") }
      it_behaves_like "json rpc method", {"jsonrpc":"2.0","method":"eth_call","params":[{to: "0x407d73d8a49eeb85d32cf465507dd71d507100c1"}, "latest"], "id":1}
    end

    describe ".eth_get_balance" do
      subject { client.eth_get_balance("0x407d73d8a49eeb85d32cf465507dd71d507100c1") }
      it_behaves_like "json rpc method", {"jsonrpc":"2.0","method":"eth_getBalance","params":["0x407d73d8a49eeb85d32cf465507dd71d507100c1", "latest"],"id":1}
    end

    describe ".get_balance" do
      let (:response) { '{"jsonrpc":"2.0","result":"0xd30beea08891180","id":1}' }
      it "returns account balance as integer" do
        expect(client).to receive(:send_single).and_return(response)
        expect(client.get_balance("0x407d73d8a49eeb85d32cf465507dd71d507100c1")). to eq 950469433750000000
      end
    end

    describe ".get_chain" do
      let (:request) { {"jsonrpc":"2.0","method":"net_version","params":[],"id":1} }
      let (:response) { '{"jsonrpc":"2.0","result":"950469433750000000","id":1}' }
      it "returns chain no" do
        expect(client).to receive(:send_single).once.with(request.to_json).and_return(response)
        expect(client.get_chain). to eq 950469433750000000
      end
    end

    describe ".get_nonce" do
      let (:request) { {"jsonrpc":"2.0","method":"eth_getTransactionCount","params":["0x407d73d8a49eeb85d32cf465507dd71d507100c1", "latest"],"id":1} }
      let (:response) { '{"jsonrpc":"2.0","result":"0xd30beea08891180","id":1}' }
      it "returns chain no" do
        expect(client).to receive(:send_single).once.with(request.to_json).and_return(response)
        expect(client.get_nonce("0x407d73d8a49eeb85d32cf465507dd71d507100c1")). to eq 950469433750000000
      end
    end

end
