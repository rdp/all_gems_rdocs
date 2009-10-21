
# load DRb
require 'drb'
require 'thread'
require 'socket'
BasicSocket.do_not_reverse_lookup = true
class Synchronized
  def initialize(this_obj)
    @self = this_obj
    @mutex = Mutex.new
   
  end

  def method_missing meth, *args
    @mutex.synchronize {
      @self.send(meth, *args) { |*incoming_args|  yield(*incoming_args) }
    }
  end
end

class Object
def start_and_run_drb_synchronized_server this_object, uri = nil # 

  # start up the DRb service
  DRb.start_service uri, Synchronized.new(this_object)

  # We need the uri of the service to connect a client
  puts DRb.uri

  DRb.thread.join
end

end