require 'spec_helper'

describe Ethereum do

  describe 'Client' do

    before :all do
      @client = Ethereum::Client.new
      @result = '{"id":1, "jsonrpc":"2.0", "result": ""}'
    end

    it 'should encode parameters' do
      params = [true, false, 0, 12345, '0x7d84abf0f241b10927b567bd636d95fa9f66ae34', '0x4d5e07d4057dd0c3849c2295d20ee1778fc29d69150e8d75a07207347dce17fa', '0x7d84abf0f241b10927b567bd636d95fa9f66ae34']
      expected = [true, false, '0x0', '0x3039', '0x7d84abf0f241b10927b567bd636d95fa9f66ae34', '0x4d5e07d4057dd0c3849c2295d20ee1778fc29d69150e8d75a07207347dce17fa', '0x7d84abf0f241b10927b567bd636d95fa9f66ae34']
      encoded_params = @client.encode_params(params)
      expect(encoded_params).to eq(expected)
    end

    def expect_to_send(expected)
      expect(@client).to receive(:send_single).with(expected.to_json).and_return('{"id":1, "jsonrpc":"2.0", "result": ""}')
      yield
    end

    it 'call json rpc methods' do
      expect_to_send({"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}) { @client.web3_client_version }
      expect_to_send({"jsonrpc":"2.0","method":"net_version","params":[],"id":1}) { @client.net_version }
      expect_to_send({"jsonrpc":"2.0","method":"eth_protocolVersion","params":[],"id":1}) { @client.eth_protocol_version }
      expect_to_send({"jsonrpc":"2.0","method":"eth_call","params":[{to: "0x407d73d8a49eeb85d32cf465507dd71d507100c1"}, "latest"], "id":1}) do
        @client.eth_call(to: "0x407d73d8a49eeb85d32cf465507dd71d507100c1") 
      end
      expect_to_send({"jsonrpc":"2.0","method":"eth_getBalance","params":["0x407d73d8a49eeb85d32cf465507dd71d507100c1", "latest"],"id":1}) do
        @client.eth_get_balance("0x407d73d8a49eeb85d32cf465507dd71d507100c1") 
      end
      expect_to_send({"jsonrpc":"2.0","method":"shh_newIdentity","params":[],"id":1}) { @client.shh_new_identity  }
    end

  end

end