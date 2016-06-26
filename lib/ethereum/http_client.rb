require 'net/http'
module Ethereum
  class HttpClient < Client
    attr_accessor :host, :port, :uri, :ssl

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

    def send_single(payload)
      http = ::Net::HTTP.new(@host, @port)
      if @ssl
        http.use_ssl = true
      end
      header = {'Content-Type' => 'application/json'}
      request = ::Net::HTTP::Post.new(uri, header)
      request.body = payload
      response = http.request(request)
      return response.body
    end

    def send_batch(batch)
      raise NotImplementedError
    end
  end

end
