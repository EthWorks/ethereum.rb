require 'spec_helper'

describe Ethereum do

  describe 'IpcClient' do
    before(:all) do
      @client = Ethereum::IpcClient.new
    end

    it 'should work' do
      expect(@client.eth_protocol_version).to be_instance_of Hash
    end

    it 'should support batching' do
      response = @client.batch do
        @client.net_listening
        @client.eth_block_number
      end

      expect(response).to be_a Array
      expect(response.length).to eq 2
      expect(response.first['result']).to be_in [true, false]
      expect(response.last['result']).to match /(0x)?[0-9a-f]+/i
    end
  end
end
