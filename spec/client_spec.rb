require 'spec_helper'

describe Ethereum do
  describe 'Client' do
    it 'should encode parameters' do
      params = [true, false, 0, 12345, '0x7d84abf0f241b10927b567bd636d95fa9f66ae34', '0x4d5e07d4057dd0c3849c2295d20ee1778fc29d69150e8d75a07207347dce17fa', '7d84abf0f241b10927b567bd636d95fa9f66ae34']
      client = Ethereum::Client.new
      encoded_params = client.encode_params(params)
      expect(encoded_params).to eq([true, false, '0x0', '0x3039', '0x7d84abf0f241b10927b567bd636d95fa9f66ae34', '0x4d5e07d4057dd0c3849c2295d20ee1778fc29d69150e8d75a07207347dce17fa', '0x7d84abf0f241b10927b567bd636d95fa9f66ae34'])
    end
  end

  describe 'HttpClient' do
    it 'should work' do
      client = Ethereum::HttpClient.new('localhost', '8545')
      expect(client.eth_accounts['error']).to eq(nil)
    end
  end

  describe 'IpcClient' do
    before(:each) do
      @client = Ethereum::IpcClient.new("#{ENV['HOME']}/EtherDev/data/geth.ipc")
    end

    it 'should work' do
      expect(@client.eth_accounts['error']).to eq(nil)
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
