module Ethereum

  class Encoder

    def encode(type, value)
      core, subtype = Abi::parse_type(type)
      method_name = "encode_#{core}".to_sym
      self.send(method_name, value)
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

    def encode_fixed(value)
      raise NotImplementedError
    end

    def encode_ufixed(value)
      raise NotImplementedError
    end

    def encode_string(value)
      raise NotImplementedError
    end

    def encode_bytes(value)
      location = encode_uint(32)
      size = encode_uint(value.size)
      content = value.each_char.map {|x| x.ord.to_s(16)}.join("").ljust(64, '0')
      location + size + content
    end

    def encode_string(value)
      location = encode_uint(32)
      size = encode_uint(value.bytes.size)
      content = value.bytes.map {|x| x.to_s(16)}.join("").ljust(64, '0')
      location + size + content
    end

    def encode_address(value)
      value = value.gsub(/^0x/,'')
      raise ArgumentError if value.size != 40
      value
    end

    private
      def to_twos_complement(number)
        (number & ((1 << 256) - 1))
      end

  end

end
