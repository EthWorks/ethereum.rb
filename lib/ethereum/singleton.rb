class Ethereum::Singleton
  
  class << self

    attr_accessor :client, :ipcpath, :host, :log, :instance, :default_account
  
    def instance
      @instance ||= configure_instance(create_instance)
    end
  
    def setup
      yield(self)
    end
    
    def reset
      @instance = nil
      @client = nil
      @host = nil
      @log = nil
      @ipcpath = nil
      @default_account = nil
    end
    
    private
      def create_instance
        return Ethereum::IpcClient.new(@ipcpath) if @client == :ipc 
        return Ethereum::HttpClient.new(@host) if @client == :http
        Ethereum::IpcClient.new
      end
      
      def configure_instance(instance)
        instance.tap do |i|
          i.default_account = @default_account if @default_account.present?
        end
      end
  end
  
  
end
