require 'net/http'
require 'json'
module Ethereum
  class HttpClient < Client
    attr_accessor :host, :port, :uri, :ssl

    def initialize(host, log = false)
      super(log)
      uri = URI.parse(host)
      raise ArgumentError unless ['http', 'https'].include? uri.scheme
      @host = uri.host
      @port = uri.port
      
      @ssl = uri.scheme == 'https'
      @uri = URI("#{uri.scheme}://#{@host}:#{@port}#{uri.path}")
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
      result = send_single(batch.to_json)
      result = JSON.parse(result)
      return result.sort_by! { |c| c['id'] }
    end
  end

end
