require 'tempfile'
require 'spec_helper'

describe Ethereum::IpcClient do

    subject { Ethereum::IpcClient.new }
    let (:version) { subject.eth_protocol_version["result"] }

    it 'is able to connect' do
      expect(version).to be_instance_of String
    end

    it 'should find default path' do
      real = Tempfile.new('real')
      deleted = Tempfile.new('deleted')
      paths = [deleted.path, real.path]
      deleted.unlink
      expect(Ethereum::IpcClient.default_path(paths)).to eq real.path
      real.unlink
    end

    it 'should support batching' do
      response = subject.batch do
        subject.net_listening
        subject.eth_block_number
      end

      expect(response).to be_a Array
      expect(response.length).to eq 2
      expect(response.first['result']).to be_in [true, false]
      expect(response.last['result']).to match /(0x)?[0-9a-f]+/i
    end

end
