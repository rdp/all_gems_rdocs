# this updates /downloads any new gems
#
puts 'syntax: --install-missing'
raise unless ARGV[0] if $0 == __FILE__

# note: currently I only do this on the ilab, then rsync over...
# important: need to use same version of ruby [like 1.8] on both sides currently
# also note: currently if you want github gems, you'll need to have github listed in your ~/.gemrc
# and also have ~/.gemrc setup to use hanna "just right"
#
# :sources:
# - http://gems.rubyforge.org/
# - http://gems.github.com
# :bulk_threshold: 1000
# rdoc: --inline-source --line-numbers --format=html --template=hanna
# gem:  --no-ri

ENV['GEM_PATH'] = '/home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/1.8'
ENV['GEM_HOME'] = ENV['GEM_PATH'] # make sure it only installs it in one place

bin_dir = '/home/rdp/dev/linode/installs/mbari_gembox_187/bin'

# currently not yet necessary
#if RUBY_PLATFORM =~ /mswin|mingw/
# bin_dir =  RbConfig::CONFIG['bindir']
#end

=begin
doctest: parses right
>> all = "\n *** LOCAL GEMS ***\n\n activesupport (2.3.2)\n cgi_multipart_eof_fix (2.5.0)"
>> parsed = get_gems(all)
>> parsed['activesupport']
=> '2.3.2'
>> parsed['cgi_multipart_eof_fix']
=> '2.5.0'
=end


def get_gems this_big_string
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

require 'rubygems'
require 'hash_set_operators'
class Object
   def in? coll
      return coll.include? self
   end
end

require 'timeout'

if $0 == __FILE__
   if ARGV[0] == '--generate_rdocs_for_all_installed_gems'
      # shouldn't need to run this ever again
      require 'rubygems' # pre load it, so fork works and doesn't have to reload rubygems which takes forever
      all = `gem list -l`
      parsed = get_gems all

      parsed.each{|name, version|
         ARGV=['rdoc', name, '--no-ri']
         p 'ARGV is', ARGV
         Process.wait fork {
            load "#{bin_dir}/gem" # install rdocs appropo
         }
         puts 'here--done with gem' + name
      }
   elsif ARGV[0] == '--install-missing'
      # note: this one assumes a correctly setup ~/.gemrc...
      all = get_gems `gem list -r`
      local = get_gems `gem list -l`
      # note todo: gem list -r --source http://gems.github.com
      new = all - local
      new.each{|name, version|
         if(name == 'rdoc')
            puts 'skipping:' + name
         else
            command = "gem install #{name} --version=#{version} --no-ri"
            puts command
            if RUBY_PLATFORM=~ /mingw|mswin/
               system(command)
            else
               require 'rubygems'
               ARGV=['install', name, '--version', version, '--no-ri', '--ignore-dependencies']
               puts 'RUNNING', ARGV.inspect, "\n\n\n\n"
               child = fork {
                  load "#{bin_dir}/gem"
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

end
puts 'done'
