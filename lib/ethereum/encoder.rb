module Ethereum

  class Encoder

    def encode(type, value)
      core, subtype = Abi::parse_type(type)
      if core == "bytes" and subtype.nil?
        encode_dynamic_bytes(value)
      else
        method_name = "encode_#{core}".to_sym
        self.send(method_name, value)
      end
    end

    def encode_int(value)
      to_twos_complement(value).to_s(16).rjust(64, '0')
    end

    def encode_uint(value)
      raise ArgumentError if value < 0
      encode_int(value)
    end

    def encode_bool(value)
      (value ? "1" : "0").rjust(64, '0')
    end

    def encode_fixed(value, n = 128)
      encode_uint((value * 2**n).to_i)
    end

    def encode_ufixed(_value)
      raise NotImplementedError
    end

    def encode_bytes(value)
      value.each_char.map {|x| x.ord.to_s(16)}.join("").ljust(64, '0')
    end

    def encode_dynamic_bytes(value)
      location = encode_uint(@inputs ? @inputs.size * 32 : 32)
      size = encode_uint(value.size)
      content = encode_bytes(value)
      [location, size + content]
    end

    def encode_string(value)
      location = encode_uint(@inputs ? @inputs.size * 32 : 32)
      size = encode_uint(value.bytes.size)
      content = value.bytes.map {|x| x.to_s(16)}.join("").ljust(64, '0')
      [location, size + content]
    end

    def encode_address(value)
      value = value.gsub(/^0x/,'')
      raise ArgumentError if value.size != 40
      value
    end

    def ensure_prefix(value)
      value.start_with?("0x") ? value : ("0x" + value)
    end

    def encode_arguments(inputs, args)
      raise "Wrong number of arguments" if inputs.length != args.length
      @head = ""
      @tail = ""
      @inputs = inputs
      inputs.each.with_index do |input, index|
        encoded = encode(input.type, args[index])
        if encoded.is_a? Array
          @head << encoded[0]
          @tail << encoded[1]
        else
          @head << encoded
        end
      end
      @head + @tail
    end

    private
      def to_twos_complement(number)
        (number & ((1 << 256) - 1))
      end

  end

end
