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

    def send_batch
      socket = UNIXSocket.new(@ipcpath)
      socket.puts(@batch.join(" "))
      read = socket.gets
      socket.close
      collection = read.chop.split("}{").collect do |output|
        if output[0] == "{"
          JSON.parse("#{output}}")["result"]
        else
          JSON.parse("{#{output}}")["result"]
        end
      end
      return collection
    end

  end
end

