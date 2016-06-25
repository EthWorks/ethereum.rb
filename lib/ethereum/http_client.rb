require 'net/http'
module Ethereum
  class HttpClient < Client
    attr_accessor :host, :port, :converted_transactions, :uri, :ssl

    def initialize(host, port, ssl = false, log = false)
      super(log)
      @host = host
      @port = port
      @ssl = ssl
      if ssl
        @uri = URI("https://#{@host}:#{@port}")
      else
        @uri = URI("http://#{@host}:#{@port}")
      end
    end

    RPC_COMMANDS.each do |rpc_command|
      method_name = "#{rpc_command.split("_")[1].underscore}"
      define_method method_name do |*args|
        command = rpc_command
        if command == "eth_call"
          args << "latest"
        end
        payload = {jsonrpc: "2.0", method: command, params: args, id: get_id}
        http = ::Net::HTTP.new(@host, @port)
        if @ssl
          http.use_ssl = true
        end
        header = {'Content-Type' => 'application/json'}
        request = ::Net::HTTP::Post.new(uri, header)
        if @log == true
          @logger.info("Sending #{payload.to_json}")
        end
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
