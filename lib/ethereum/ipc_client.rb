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

    # TODO: Not sure if multithread safe
    # Note: Guarantees the results are in the same order as defined in batch call.
    # client.batch do
    #   client.eth_block_number
    #   client.eth_mining
    # end
    # => [{"jsonrpc"=>"2.0", "id"=>1, "result"=>"0x26"}, {"jsonrpc"=>"2.0", "id"=>2, "result"=>false}] 
    def send_batch(batch)
      result = send_single(batch.to_json)
      result = JSON.parse(result)

      # Make sure the order is the same as it was when batching calls
      # See 6 Batch here http://www.jsonrpc.org/specification
      return result.sort_by! { |c| c['id'] }
    end
  end
end