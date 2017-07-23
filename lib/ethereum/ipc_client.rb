require 'socket'
module Ethereum
  class IpcClient < Client
    attr_accessor :ipcpath

    IPC_PATHS = [
      "#{ENV['HOME']}/.parity/jsonrpc.ipc",
      "#{ENV['HOME']}/Library/Ethereum/geth.ipc",
      "#{ENV['HOME']}/Library/Ethereum/testnet/geth.ipc",
      "#{ENV['HOME']}/Library/Application\ Support/io.parity.ethereum/jsonrpc.ipc",
      "#{ENV['HOME']}/.local/share/parity/jsonrpc.ipc",
      "#{ENV['HOME']}/.local/share/io.parity.ethereum/jsonrpc.ipc",
      "#{ENV['HOME']}/AppData/Roaming/Parity/Ethereum/jsonrpc.ipc",
      "#{ENV['HOME']}/.ethereum/geth.ipc",
      "#{ENV['HOME']}/.ethereum/testnet/geth.ipc"
    ]

    def initialize(ipcpath = nil, log = true)
      super(log)
      ipcpath ||= IpcClient.default_path
      @ipcpath = ipcpath
    end

    def self.default_path(paths = IPC_PATHS)
      path = paths.select { |path| File.exist?(path) }.first
      path || raise("Ipc file not found. Please pass in the file path explicitly to IpcClient initializer")
    end

    def send_single(payload)
      socket = UNIXSocket.new(@ipcpath)
      socket.puts(payload)
      read = socket.recvmsg(nil)[0]
      socket.close
      return read
    end

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
