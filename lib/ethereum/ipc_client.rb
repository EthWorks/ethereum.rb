require 'socket'
module Ethereum
  class IpcClient < Client
    attr_accessor :ipcpath

    def initialize(ipcpath = "#{ENV['HOME']}/.ethereum/geth.ipc", log = false)
      super(log)
      @ipcpath = ipcpath
    end

    def send_single(payload)
      socket = UNIXSocket.new(@ipcpath)
      socket.puts(payload)
      read = socket.gets
      socket.close
      return read
    end

  end
end

