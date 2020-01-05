$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ethereum'
require 'pry'

# use ganache
begin
  TCPSocket.open('localhost', 7545)
  Ethereum::Singleton.host = 'http://localhost:7545'
  Ethereum::Singleton.client = :http
rescue
  puts 'ganache is not running!!'
end
