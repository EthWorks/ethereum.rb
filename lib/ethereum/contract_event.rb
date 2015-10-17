require 'pry'
module Ethereum
  class ContractEvent

    attr_accessor :name, :signature, :input_types, :inputs, :event_string 

    def initialize(data)
      @name = data["name"]
      @input_types = data["inputs"].collect {|x| x["type"]}
      @inputs = data["inputs"].collect {|x| x["name"]}
      @event_string = "#{@name}(#{@input_types.join(",")})"
      @signature = Digest::SHA3.hexdigest(@event_string, 256)
    end

  end
end

