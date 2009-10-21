# this is just a library--never actually run
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
      @self.send(meth, *args){ |*incoming_args|  yield(*incoming_args) }
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

if $0 == __FILE__
  start_and_run_drb_synchronized_server [1,2,3], "druby://0.0.0.0:3333"
end
  
