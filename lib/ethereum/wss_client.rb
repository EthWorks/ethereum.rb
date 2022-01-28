require 'open3'
require 'json'

module Ethereum
  class WssConnection
    attr_accessor :host,:ws_in,:ws_out,:ws_err,:wait_thr,:index

    def read_all_buf()
        ret = ""
        loop do
            begin
                loop do
                    ret = ret + @ws_out.read_nonblock(1024*1024)
                end
            rescue IO::WaitReadable
            end

            last = ret[-5,5]
            break if last=="}\n\n> "
            last = ret[-3,3]
            break if last=="}\n\n"
        end
        return ret
    end    

    def initialize(host)
        @host = host
        get_ws()
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

    def write_nonblock(str)
        begin
            @ws_in.write_nonblock(str)
        rescue Errno::EPIPE
            get_ws()
            retry
        end
    end

  end

  class WssClient < Client
    attr_accessor :host #,:ws_in,:ws_out,:ws_err,:wait_thr
    attr_accessor :pool,:semaphore

    POOL_SIZE = 10

    def change_pool_status(ws,status)
        @pool.map! do |x|
            x[1]=status if x[0]==ws
            x
        end
    end
    
    def get_pool_ws()
        action = nil
        
        semaphore.synchronize{ 
            open_pool = @pool.filter do |x| x[1]=="open" end
            if open_pool.size == 0 then 
                action= "new"
            else
                ws = open_pool[0][0]
                change_pool_status(ws,"work")
                return ws
            end            
        }

        if action=="new" then
            new_ws = WssConnection.new(@host)
            @pool << [new_ws,"work"]
            return new_ws
        end
    end



    def release_pool_ws(ws)
        change_pool_status(ws,"open")
    end

    def initialize(host, log = false)
        super(log)
        @host = host
        @pool = []
        @semaphore = Mutex.new
    end
  
    def send_single(payload)
        ws = get_pool_ws()
        ws.write_nonblock(payload+"\n")

        ret = ""
        loop do
            ret=ws.read_all_buf()
            ret=ret[2,ret.size-2] if ret[0]==">" and ret[1]==" "
            ret=ret[0,ret.size-2] if ret[-2]==">" and ret[-1]==" "
            break if ret!=""
        end
        release_pool_ws(ws)
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
