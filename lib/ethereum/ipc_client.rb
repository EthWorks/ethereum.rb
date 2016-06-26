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

    def send_batch(batch)
      result = send_single(batch.to_json)
      result = JSON.parse(result)

      # Make sure the order is the same as it was when batching calls
      # See 6 Batch here http://www.jsonrpc.org/specification
      return result.sort_by! { |c| c['id'] }
    end
  end
end