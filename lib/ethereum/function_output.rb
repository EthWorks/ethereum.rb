module Ethereum
  
  class FunctionOutput

    attr_accessor :type, :name

    def initialize(data)
      @type = data["type"]
      @name = data["name"]
    end

  end

end
