
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

# start up the DRb service
DRb.start_service nil, Synchronized.new(['line 1', 'line 2'])

# We need the uri of the service to connect a client
puts DRb.uri

DRb.thread.join

