module Ethereum
  class Function

    attr_accessor :name, :inputs, :outputs, :signature, :constant, :function_string 

    def initialize(data)
      @name = data["name"]
      @constant = data["constant"]
      @inputs = data["inputs"].collect do |input|
        Ethereum::FunctionInput.new(input)
      end
      @outputs = data["outputs"].collect do |output|
        Ethereum::FunctionOutput.new(output)
      end
      @function_string = "#{@name}(#{@inputs.collect {|x| x.type }.join(",")})"
      @signature = Digest::SHA3.hexdigest(@function_string, 256)[0..7]
    end

  end
end
