class Ethereum::Singleton
  
  class << self

    attr_accessor :client, :ipcpath, :host, :log, :instance
  
    def instance
      @instance ||= create_instance
    end
  
    def setup(&block)
      yield(self)
    end
    
    def reset
      @instance = nil
      @client = nil
      @host = @log = @ipcpath = nil
    end
    
    private
      def create_instance
        return Ethereum::IpcClient.new(@ipcpath) if @client == :ipc 
        return Ethereum::HttpClient.new(@host) if @client == :http
        nil
      end
  end
  
  
end