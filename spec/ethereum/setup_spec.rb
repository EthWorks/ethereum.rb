require 'tempfile'
require 'spec_helper'

describe 'Ethereum::Singleton.instance' do

    it 'should setup to IpcClient' do
      Ethereum::Singleton.reset
      Ethereum::Singleton.setup do |c|
        c.client = :ipc        
        c.ipcpath = "/tmp/some.ipc"
        c.log = true
      end
      instance = Ethereum::Singleton.instance
      expect(instance).to be_an_instance_of(Ethereum::IpcClient)
      expect(instance.ipcpath).to eq "/tmp/some.ipc"
      expect(instance.log).to be true
    end

    it 'should setup to HttpClient' do
      Ethereum::Singleton.reset
      Ethereum::Singleton.setup do |c|
        c.client = :http
        c.host = "http://121.1.1.1:80"
        c.log = false
      end
      instance = Ethereum::Singleton.instance
      expect(instance).to be_an_instance_of(Ethereum::HttpClient)
      expect(instance.host).to eq "121.1.1.1"
      expect(instance.port).to eq 80
      expect(instance.log).to be false
    end
    
    it 'should be nil if no setup was done' do
      Ethereum::Singleton.reset
      expect(Ethereum::Singleton.instance).to be_nil
    end

end