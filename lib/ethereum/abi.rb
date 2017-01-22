module Ethereum
  class Abi

    def self.parse_abi(abi)
      constructor_inputs = abi.detect {|x| x["type"] == "constructor"}["inputs"] rescue nil
      functions = abi.select {|x| x["type"] == "function" }.map { |fun| Ethereum::Function.new(fun) }
      events = abi.select {|x| x["type"] == "event" }.map { |evt| Ethereum::ContractEvent.new(evt) }
      [constructor_inputs, functions, events]
    end

    def self.parse_type(type)
      match = /(\D+)(\d.+)?/.match(type)
      [match[1], match[2]]
    end
    
  end
end
