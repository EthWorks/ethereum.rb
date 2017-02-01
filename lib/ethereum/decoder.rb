module Ethereum
  class Decoder

    #TODO: trim
    def decode(type, value, start = 0)
      value = value.gsub(/^0x/,'')
      core, subtype = Abi::parse_type(type)
      method_name = "decode_#{core}".to_sym
      if "string" == core
        self.send(method_name, value, start)
      elsif "int" == core
        size = subtype.present? ? subtype.to_i : 256
        self.send(method_name, trim(value, start, size), size)
      else
        self.send(method_name, value, subtype, start)
      end
    end

    def decode_fixed(value, subtype = "128x128", _)
      n = subtype.nil? ? 128 : /(\d+)x(\d+)/.match(subtype)[2].to_i
      decode_int(value).to_f / 2**n
    end

    def decode_uint(value, _subtype = nil, _ = nil)
      value.hex
    end

    def decode_int(value, size = 256, _ = nil)
      raise ArgumentError if value.nil?
      (value[0..1] == "ff") ? (value.hex - (2 ** size)) : value.hex
    end

    def decode_bool(value, _, _)
      return true if value == "0000000000000000000000000000000000000000000000000000000000000001"
      return false if value == "0000000000000000000000000000000000000000000000000000000000000000"
      raise ArgumentError
    end

    def decode_address(value, _ = nil, _)
      raise ArgumentError if value.size != 40
      value
    end

    def decode_bytes(value, subtype, start)
      subtype.nil? ? decode_dynamic_bytes(value, start) : decode_static_bytes(value, subtype)
    end

    def decode_static_bytes(value, _subtype = nil)
      value.scan(/.{2}/).collect {|x| x.hex}.pack('C*').strip
    end

    def decode_dynamic_bytes(value, start = 0)
      location = decode_uint(value[start..(start+63)]) * 2
      size = decode_uint(value[location..location+63]) * 2
      value[location+64..location+63+size].scan(/.{2}/).collect {|x| x.hex}.pack('C*')
    end

    def decode_string(value, start = 0)
      decode_dynamic_bytes(value, start).force_encoding('utf-8')
    end

    def decode_arguments(arguments, data)
      data = data.gsub(/^0x/,'')
      types = arguments.map { |o| o.type }
      types.each.with_index.map { |t , i| decode(t, data, i*64) }
    end

    private 
      def trim(value, start, bitsize = 256)
        value[start+63-(bitsize/4-1)..start+63]
      end
      
  end
end
