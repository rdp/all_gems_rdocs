#!/usr/bin/env ruby -w
# simple_client.rb
# A simple DRb client

require 'drb'
BasicSocket.do_not_reverse_lookup = true

#DRb.start_service

# attach to the DRb server via a URI given on the command line
remote_array = DRbObject.new nil, ARGV.shift

puts remote_array.size

puts remote_array.pop

puts remote_array.size
