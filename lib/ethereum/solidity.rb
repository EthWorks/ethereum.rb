module Ethereum
  class Solidity

    def initialize(tmp_path = nil, bin_path = "solc")
      @tmp_path = Pathname.new(tmp_path || "#{Dir.pwd}/tmp")
      @bin_path = bin_path
    end

    def compile(filename)
      args = "--bin --abi --userdoc --devdoc --add-std --optimize -o"
      cmd = "#{@bin_path} #{args} '#{@tmp_path}' '#{filename}'"
      raise SystemCallError, "Unanable to run solc compliers" unless system(cmd)
      abi = file_for(filename, 'abi')
      bin = file_for(filename, 'bin')
      {abi: abi, bin: bin}
    end
  
    def file_for(path, extension)
      File.read(path_for(path, extension))
    end
  
    def path_for(path, extension)
      path = Pathname.new(path).basename(".sol")
      @tmp_path.join("#{path}.#{extension}")
    end

  end
end