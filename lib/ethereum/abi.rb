module Ethereum
  class Abi

    def self.parse_abi(abi)
      functions = []
      events = []
      constructor_inputs = abi.detect {|x| x["type"] == "constructor"}["inputs"] rescue nil
      abi.select {|x| x["type"] == "function" }.each do |abifun|
        functions << Ethereum::Function.new(abifun) 
      end
      abi.select {|x| x["type"] == "event" }.each do |abievt|
        events << Ethereum::ContractEvent.new(abievt)
      end
      [constructor_inputs, functions, events]
    end
    
  end
end
