require 'tmpdir'
require 'open3'

module Ethereum
  class CompilationError < StandardError;
    def initialize(msg)
      super
    end
  end

  class Solidity

    OUTPUT_REGEXP = /======= (\S*):(\S*) =======\s*Binary:\s*(\S*)\s*Contract JSON ABI\s*(.*)/

    def initialize(bin_path = "solc")
      @bin_path = bin_path
      @args = "--bin --abi --optimize"
    end

    def compile(filename)
      result = {}
      execute_solc(filename).scan(OUTPUT_REGEXP).each do |match|
        _file, name, bin, abi = match
        result[name] = {}
        result[name]["abi"] = abi
        result[name]["bin"] = bin
      end
      result
    end

    private
      def execute_solc(filename)
        cmd = "#{@bin_path} #{@args} '#{filename}'"
        out, stderr, status = Open3.capture3(cmd)
        raise SystemCallError, "Unanable to run solc compliers" if status.exitstatus == 127
        raise CompilationError, stderr unless status.exitstatus == 0
        out
      end
  end
end
