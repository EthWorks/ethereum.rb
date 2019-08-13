module Ethereum
  class FunctionInput

    attr_accessor :type, :name, :components

    def initialize(data)
      @type = data["type"]
      @name = data["name"]
      @components = data["components"]
    end

  end

end
