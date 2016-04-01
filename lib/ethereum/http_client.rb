require 'net/http'
module Ethereum
  class HttpClient < Client
    attr_accessor :command, :id, :host, :port, :batch, :converted_transactions, :uri

    def initialize(host, port, ssl = false)
      @host = host
      @port = port
      @id = 1
      if ssl
        @uri = URI("https://#{@host}:#{@port}")
      else
        @uri = URI("http://#{@host}:#{@port}")
      end
      @batch = []
    end

    RPC_COMMANDS.each do |rpc_command|
      method_name = "#{rpc_command.split("_")[1].underscore}"
      define_method method_name do |*args|
        command = rpc_command
        payload = {jsonrpc: "2.0", method: command, params: args, id: get_id}
        http = ::Net::HTTP.new(@host, @port)
        header = {'Content-Type' => 'application/json'}
        request = ::Net::HTTP::Post.new(uri, header)
        request.body = payload.to_json
        response =  http.request(request)
        return JSON.parse(response.body)
      end

      define_method "#{method_name}_batch" do |*args|
        command = rpc_command
        payload = {jsonrpc: "2.0", method: command, params: args, id: get_id}
        @batch << payload.to_json
      end
    end

    def send_batch

    end

  end

end
