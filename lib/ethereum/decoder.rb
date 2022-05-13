module Ethereum
  class Decoder

    def decode(type, value, start = 0)
      is_array, arity, array_subtype = Abi::parse_array_type(type)
      if is_array && arity
        decode_static_array(arity, array_subtype, value, start)
      elsif is_array
        decode_dynamic_array(array_subtype, value, start)
      else
        @is_hex_value = value.start_with?("0x")
        value = value.gsub(/^0x/,'')
        core, subtype = Abi::parse_type(type)
        method_name = "decode_#{core}".to_sym
        self.send(method_name, value, subtype, start)
      end
    end

    def decode_static_array(arity, array_subtype, value, start)
      (0..arity-1).map { |i| decode(array_subtype, value, start + i * 64) }
    end

    def decode_dynamic_array(array_subtype, value, start)
      location = decode_uint(value[start..(start+63)]) * 2
      size = decode_uint(value[location..location+63])
      (0..size-1).map { |i| decode(array_subtype, value, location + (i+1) * 64) }
    end

    def decode_fixed(value, subtype = "128x128", start = 0)
      decode_int(trim(value, start, fixed_bitsize(subtype))).to_f / 2**exponent(subtype)
    end

    def decode_uint(value, subtype = "256", start = 0)
      trim(value, start, bitsize(subtype)).hex
    end

    def decode_int(value, subtype = "256", start = 0)
      raise ArgumentError if value.nil?
      size = bitsize(subtype)
      value = trim(value, start, size)
      (value[0..1] == "ff") ? (value.hex - (2 ** size)) : value.hex
    end

    def decode_bool(value, _, start)
      value = trim(value, start, 4)
      return true if value == "1"
      return false if value == "0"
      raise ArgumentError
    end

    def decode_address(value, _ = nil, start)
      raise ArgumentError if value.size-start < 64
      value[start+24..start+63]
    end

    def decode_bytes(value, subtype, start)
      subtype.present? ? decode_static_bytes(value, subtype, start) : decode_dynamic_bytes(value, start)
    end

    def decode_static_bytes(value, subtype = nil, start = 0)
      trimed_value = trim(value, start, subtype.to_i*8).scan(/.{2}/)
      if @is_hex_value
        trimed_value.join
      else
        trimed_value.collect {|x| x.hex}.pack('C*').strip
      end
    end

    def decode_dynamic_bytes(value, start = 0)
      location = decode_uint(value[start..(start+63)]) * 2
      size = decode_uint(value[location..location+63]) * 2
      value[location+64..location+63+size].scan(/.{2}/).collect {|x| x.hex}.pack('C*')
    end

    def decode_string(value, _ = nil, start = 0)
      decode_dynamic_bytes(value, start).force_encoding('utf-8')
    end

    def decode_arguments(arguments, data, start = 0)
      data = data.gsub(/^0x/,'')
      types = arguments.map { |o| o.type }
      i = start
      types.map do |t |
        if t == "tuple"
          args = decode_arguments(arguments[i].components, data, i)
          i += arguments[i].components.size - 1
        else
          args = decode(t, data, i*64)
        end
        i += 1
        args
      end
    end

    private
      def trim(value, start, bitsize = 256)
        value[start+63-(bitsize/4-1)..start+63]
      end

      def bitsize(subtype, default = 256)
        subtype.present? ? subtype.to_i : default
      end

      def fixed_bitsize(subtype = nil)
        subtype ||= "128x128"
        _, x, n = /(\d+)x(\d+)/.match(subtype).to_a
        x.to_i + n.to_i
      end

      def exponent(subtype, default = 128)
        subtype.nil? ? default : /(\d+)x(\d+)/.match(subtype)[2].to_i
      end

  end
end
