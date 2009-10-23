#!/usr/bin/env ruby
# this updates|downloads any new gems
#
# important: need to use same version of ruby [like 1.8] on both sides currently
# also note: currently if you want github gems, you'll need to have github listed in your ~/.gemrc
# and also you need to have ~/.gemrc setup to use hanna "just right"
#
# :sources:
# - http://gems.rubyforge.org/
# - http://gems.github.com
# :bulk_threshold: 1000
# rdoc: --inline-source --line-numbers --format=html --template=hanna
# gem:  --no-ri

if $0 == __FILE__
  # setup
  ENV['GEM_PATH'] = '/home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/1.8'
  ENV['GEM_HOME'] = ENV['GEM_PATH'] # make sure it only installs it in one place
  require 'rubygems'
  Gem.clear_paths # just in case we need to...
end
$bin_dir =  RbConfig::CONFIG['bindir']

module Process
  require 'timeout'
  def self.kill_process_after(pid, seconds)
    begin
      Timeout::timeout(60*5) {
        Process.wait pid
      }
    rescue Exception
      # timeout -- kill it :) -- does this work in doze?
      Process.kill 9, pid
    end
  end
end

class Object
  def rdoc_these_gems gems
    gems.each{|name, version|
      ARGV.clear
      ARGV << 'rdoc'; ARGV << name; ARGV << '--no-ri'
      p 'ARGV is', ARGV
      pid = fork {
        load "#{$bin_dir}/gem" # install rdocs appropo
      }
      Process.kill_process_after(pid, 5*60)
      puts 'here--done with gem' + name
    }
  end
end

module Kernel
  def install_these_gems gems
    gems.each{|name, version|
      if(name == 'rdoc') # sdoc, etc. also would have installed this as a dependency--we don't let them, though
        puts 'skipping:' + name
      else

        commands = ['install', name, '--no-ri', '--ignore-dependencies', '--rdoc']
        if RUBY_PLATFORM=~ /mingw|mswin/
          require 'win32-process'
          # this way is still slow since it has to reload all the gems each time
          # could be made faster by every so often you copy [and nuke] your stuff into the main.  I suppose.
          child = Process.create :command_line => commands.join(' ')

        else
          require 'rubygems'
          ARGV.clear
          for name in commands  do; ARGV << name; end
          if version
            ARGV << '--version'
            ARGV << version
          end
          child = fork {
            load "#{$bin_dir}/gem"
          }
        end
        Process.kill_process_after(child, 60*5)
      end
    }
  end
end

puts '--one-time-bootstrap'
if ARGV[0] == '--one-time-bootstrap'
  commandss = []
  commandss << ['install', 'gem_dependencies/rdoc*.gem', '--no-rdoc', '--no-ri']
  for gem in Dir['gem_dependencies/*.gem']
    commandss << ['install', gem, '--no-rdoc', '--no-ri']
  end
  for commands in commandss
    ARGV.clear
    for command in commands
      ARGV << command
    end
    puts 'running', ARGV.inspect
    begin
      load "#{$bin_dir}/gem"
    rescue Exception
    end
    puts 'done running', ARGV
  end
  puts 'must also update ~/.gemrc'
end

=begin
doctest: parses right
>> all = "\n *** LOCAL GEMS ***\n\n activesupport (2.3.2)\n cgi_multipart_eof_fix (2.5.0)"
>> parsed = parse_gems(all)
>> parsed['activesupport']
=> '2.3.2'
>> parsed['cgi_multipart_eof_fix']
=> '2.5.0'
=end

def parse_gems this_big_string
  all_gems = {}
  this_big_string.each_line {|line|

    line =~ /(.*) \((.*)\)/
    next unless $1 # first few lines are bunk [?] necessary?
    name = $1.strip # strip just in case...
    versions = $2
    versions = versions.split(', ')
    all_gems[name] = versions.sort.last # latest one...
  }
  return all_gems
end

require 'sane'
require 'timeout'

class Object

  # which => '--install-missing' or '--run-server' or '--just-list'
  def do_install_or_server which
    all = parse_gems `gem list -r`
    local = parse_gems `gem list -l`
    # todo: gem list -r --source http://gems.github.com
    new = all - local
    if which == '--install-missing'
      install_these_gems new
    elsif which == '--run-server'
      require_rel 'server.rb'
      puts 'running server'
      start_and_run_drb_synchronized_server new.to_a, 'druby://0.0.0.0:3333'
    end
    new
  end

end


puts '--run-web-client'
puts '--install-missing (local only)'
puts '--run-server'
puts '--run-client'
if ARGV[0] == '--generate_rdocs_for_all_installed_gems'
  # shouldn't need to run this ever again
  require 'rubygems' # pre load it, so fork works and doesn't have to reload rubygems which takes forever
  all = `gem list -l`
  parsed = parse_gems all
  rdoc_these_gems parsed
elsif ARGV[0].in? ['--install-missing', '--run-server']
  # note: this one assumes a correctly setup ~/.gemrc...
  do_install_or_server ARGV[0]
elsif ARGV[0].in? ['--run-client', '--run-web-client']
  require 'drb'
  if ARGV[0] == '--run-client'
    remote_array = DRbObject.new nil, 'druby://10.52.81.149:3333'
  else
    require 'open-uri'
    class WebGuy
      def pop
        open('http://localhost:5678/next') {|f| f.read }
      end
    end    
    remote_array = WebGuy.new
  end
  require 'forkmanager'
  pfm = Parallel::ForkManager.new(2)

  while(got = remote_array.pop)
    puts got
    if RUBY_VERSION !~ /mingw|mswin/
      # linux
      pfm.start(got) and next # blocks until a new fork is available
      puts Process.pid
      install_these_gems [got]
      pfm.finish(0) # exit status 0 for this fork
    else
      install_these_gems [got] # single threaded
    end
  end
  pfm.wait_all_children # let the laggers finish up
end

puts 'done'
