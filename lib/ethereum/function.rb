module Ethereum
  class Function

    attr_accessor :name, :inputs, :outputs, :signature, :constant, :function_string 

    def initialize(data)
      @name = data["name"]
      @constant = data["constant"]
      @inputs = data["inputs"].map do |input|
        Ethereum::FunctionInput.new(input)
      end
      @outputs = data["outputs"].collect do |output|
        Ethereum::FunctionOutput.new(output)
      end
      @function_string = self.class.calc_signature(@name, @inputs)
      @signature = self.class.calc_id(@function_string)
    end

    def self.to_canonical_type(type)
      type
      .gsub(/(int)(\z|\D)/, '\1256\2')
      .gsub(/(uint)(\z|\D)/, '\1256\2')
      .gsub(/(fixed)(\z|\D)/, '\1128x128\2')
      .gsub(/(ufixed)(\z|\D)/, '\1128x128\2')
    end

    def self.input_to_string(input)
      tuple_match = /tuple(.*)/.match(input.type)
      if tuple_match
        "(#{input.components.collect {|component| self.to_canonical_type(component.with_indifferent_access[:type]) }.join(",")})#{tuple_match[1]}"
      else
        self.to_canonical_type(input.type)
      end
    end

    def self.calc_signature(name, inputs)
      "#{name}(#{inputs.collect {|input| self.input_to_string(input) }.join(",")})"
    end

    def self.calc_id(signature)
      Digest::SHA3.hexdigest(signature, 256)[0..7]
    end

  end
end
