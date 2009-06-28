# this does install and generate rdocs
# requires
#  $ cat ~/.gemrc
#  rdoc: --inline-source --line-numbers --format=html --template=hanna
#
puts 'syntax: --generate_rdocs [unused], --install-missing'
raise unless ARGV[0] if $0 == __FILE__
# note: I only do this on the ilab, then rsync over...

ENV['GEM_PATH'] = '/home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/1.8'

bin_dir = '/home/rdp/dev/linode/installs/mbari_gembox_187/bin'

# currently not yet necessary/useful
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

require 'hash_set_operators'
class Object
def in? coll
 return coll.include? self
end
end

if $0 == __FILE__
   if ARGV[0] == '--generate_rdocs'
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
        if(name.include?('sdoc') || name.in?(['rdoc']))
           puts 'skipping:' + name
        else
        command = "gem install #{name} --version=#{version} --no-ri"
        puts command
          if RUBY_PLATFORM=~ /mingw|mswin/
             system(command)
          else
             require 'rubygems'
             ARGV=['install', name, '--version=', version, '--no-ri']
             Process.wait fork {
                load #{bin_dir}/gem"
             } 
          end
        end
      }
   end

end
