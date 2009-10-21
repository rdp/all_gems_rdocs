# this updates|downloads any new gems
#
puts 'syntax: see file itself'
raise unless ARGV[0] if $0 == __FILE__

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

ENV['GEM_PATH'] = '/home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/1.8'
ENV['GEM_HOME'] = ENV['GEM_PATH'] # make sure it only installs it in one place
require 'rubygems'
Gem.clear_paths # just in case we need to...
$bin_dir =  RbConfig::CONFIG['bindir']

def rdoc_these_gems gems
      gems.each{|name, version|
         ARGV.clear
         ARGV << 'rdoc'; ARGV << name; ARGV << '--no-ri'
         p 'ARGV is', ARGV
         Process.wait fork {
            load "#{$bin_dir}/gem" # install rdocs appropo
         }
         puts 'here--done with gem' + name
    }
end


def install_these_gems gems
      gems.each{|name, version|
         if(name == 'rdoc') # sdoc, etc. also would have installed this as a dependency--we don't let them, though
            puts 'skipping:' + name
         else
            command = "gem install #{name} --version=#{version} --no-ri"
            puts command
            if RUBY_PLATFORM=~ /mingw|mswin/
               system(command) # the slow way
            else
               require 'rubygems'
               ARGV.clear 
               for name in ['install', name, '--no-ri', '--ignore-dependencies'] do; ARGV << name; end
               if version
                 # add it in
                 ARGV << '--version'
                 ARGV << version
               end
               puts 'RUNNING', ARGV.inspect, "\n\n\n\n"
               child = fork {
                  load "#{$bin_dir}/gem"
               }
               begin
                 Timeout::timeout(60*5) {
                      Process.wait child
                 }
               rescue Exception
                 # timeout -- kill it :)
                 Process.kill 9, child
               end
            end
         end
      }
end

if ARGV[0] == '--one-time-bootstrap'
   ARGV.clear
   ARGV << 'install'
   ARGV << 'gem_dependencies/*.gem'
   load "#{$bin_dir}/gem"
   raise 'not an error -- you should be ready to go'
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

   if ARGV[0] == '--generate_rdocs_for_all_installed_gems'
      # shouldn't need to run this ever again
      require 'rubygems' # pre load it, so fork works and doesn't have to reload rubygems which takes forever
      all = `gem list -l`
      parsed = parse_gems all
      rdoc_these_gems parsed
   elsif ARGV[0] == '--install-missing'
      # note: this one assumes a correctly setup ~/.gemrc...
      all = parse_gems `gem list -r`
      local = parse_gems `gem list -l`
      # todo: gem list -r --source http://gems.github.com
      new = all - local
      install_these_gems new
   end
puts 'done'
