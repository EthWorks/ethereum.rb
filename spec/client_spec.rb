require 'spec_helper'

describe Ethereum do
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
