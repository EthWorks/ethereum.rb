require 'open3'
require 'json'

module Ethereum
  class WssClient < Client
    attr_accessor :host,:ws_in,:ws_out,:ws_err,:wait_thr

    
    def read_all_buf()
        ret = ""
        begin
            loop do
                ret = ret + @ws_out.read_nonblock(1024*1024)
            end
        rescue IO::WaitReadable
        end
        return ret
    end    


    def get_ws()
        if @wait_thr and @wait_thr.status==false then
            #close io
            @ws_in.close 
            @ws_out.close
            @ws_err.close
            @wait_thr = nil
        end

        if @wait_thr==nil then
            @ws_in, @ws_out,@ws_err, @wait_thr = Open3.popen3("wscat -c #{@host}")
            #wait until pipe ready

            payload = "{\"jsonrpc\":\"2.0\",\"method\":\"web3_clientVersion\",\"params\":[],\"id\":1}"
            loop do
                @ws_in.write_nonblock(payload+"\n")
                io_sel = IO.select([@ws_out],[],[],0.01)
                break if io_sel!=nil
            end
            loop do
                ret=read_all_buf()
                ret=ret.gsub(/^> |> =$/,"")
                break if ret!=""
            end
        end
        return @ws_in,@ws_out,@ws_err,@wait_thr
    end

    def initialize(host, log = false)
        super(log)
        @host = host
        get_ws() 
    end
  
    def send_single(payload)
        @ws_in.write_nonblock(payload+"\n")
        ret = ""
        loop do
            ret=read_all_buf()
            ret=ret[2,ret.size-2] if ret[0]==">" and ret[1]==" "
            ret=ret[0,ret.size-2] if ret[-2]==">" and ret[-1]==" "
            break if ret!=""
        end
        return ret
    end


    # Note: Guarantees the results are in the same order as defined in batch call.
    # client.batch do
    #   client.eth_block_number
    #   client.eth_mining
    # end
    # => [{"jsonrpc"=>"2.0", "id"=>1, "result"=>"0x26"}, {"jsonrpc"=>"2.0", "id"=>2, "result"=>false}] 
    def send_batch(batch)
      result = send_single(batch.to_json)
      result = JSON.parse(result)

      # Make sure the order is the same as it was when batching calls
      # See 6 Batch here http://www.jsonrpc.org/specification
      result.sort_by! { |c| c['id'] }
    end
  end

end
