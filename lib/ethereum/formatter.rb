module Ethereum
  class Formatter

    def from_bool(boolval)
      boolval ? "1" : "0"
    end

    def to_bool(hexstring)
      (hexstring == "0000000000000000000000000000000000000000000000000000000000000001")
    end

    def to_ascii(hexstring)
      hexstring.gsub(/^0x/,'').scan(/.{2}/).collect {|x| x.hex}.pack("c*")
    end
    
    def to_utf8(hexstring)
      hexstring.gsub(/^0x/,'').scan(/.{2}/).collect {|x| x.hex}.pack("U*").delete("\u0000")
    end

    def from_ascii(ascii_string)
      ascii_string.unpack('H*')[0]
    end

    def from_utf8(utf8_string)
      utf8_string.force_encoding('UTF-8').split("").collect {|x| x.ord.to_s(16)}.join("")
    end

    def to_address(hexstring)
      "0x" + hexstring[-40..-1]
    end

    def from_address(address)
      address.gsub(/^0x/,'').rjust(64, "0")
    end

    def to_param(string)
      string.ljust(64, '0')
    end

    def from_input(string)
      string[10..-1].scan(/.{64}/)
    end

    def to_twos_complement(number)
      (number & ((1 << 256) - 1)).to_s(16)
    end

    def to_int(hexstring)
      (hexstring.gsub(/^0x/,'')[0..1] == "ff") ? (hexstring.hex - (2 ** 256)) : hexstring.hex
    end

    def address_to_payload(address)
      from_address(address)
    end

    def uint_to_payload(uint)
      self.to_twos_complement(uint)
    end

    def int_to_payload(int)
      self.to_twos_complement(uint)
    end

    def bytes_to_payload(bytes)
      self.from_utf8(bytes).ljust(64, '0')
    end

    def get_base_type(typename)
      typename.gsub(/\d+/,'')
    end

    def to_payload(args)
      converter = "#{self.get_base_type(args[0])}_to_payload".to_sym
      self.send(converter, args[1]) 
    end

    def output_to_address(bytes)
      self.to_address(bytes)
    end

    def output_to_bytes(bytes)
      self.to_utf8(bytes)
    end

    def output_to_uint(bytes)
      self.to_int(bytes)
    end

    def output_to_int(bytes)
      self.to_int(bytes)
    end

    def to_output(args)
      converter = "output_to_#{self.get_base_type(args[0])}".to_sym
      self.send(converter, args[1])
    end

  end

end
