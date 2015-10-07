module Ethereum
  class FunctionInput

    attr_accessor :type, :name

    def initialize(data)
      @type = data["type"]
      @name = data["name"]
    end

  end

end
