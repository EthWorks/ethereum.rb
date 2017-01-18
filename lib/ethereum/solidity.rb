require 'tmpdir'
require 'open3'

module Ethereum
  class CompilationError < StandardError; 
    def initialize(msg)
      super
    end
  end

  class Solidity

    def initialize(bin_path = "solc")
      @bin_path = bin_path
      @args = "--bin --abi --userdoc --devdoc --add-std --optimize -o"      
    end

    def compile(filename)
      {}.tap do |result|
        Dir.mktmpdir do |dir|
          execute_solc(dir, filename)
          Dir.foreach(dir) do |file|
            process_file(dir, file, result)
          end
        end
      end
    end
    
    private    
      def process_file(dir, file, result)
        extension = File.extname(file)
        path = "#{dir}/#{file}"
        basename = File.basename(path, extension)
        unless File.directory?(path)
          result[basename] ||= {}
          result[basename][extension[1..-1]] = File.read(path) 
        end
      end
      
      def execute_solc(dir, filename)
        cmd = "#{@bin_path} #{@args} '#{dir}' '#{filename}'"
        _, stderr, status = Open3.capture3(cmd)
        raise SystemCallError, "Unanable to run solc compliers" if status.exitstatus == 127
        raise CompilationError, stderr unless status.exitstatus == 0
      end    
  end 
end