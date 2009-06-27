# this does install and generate rdocs
# requires
#  cat ~/.gemrc
#  rdoc: --inline-source --line-numbers --format=html --template=hanna
#
puts 'syntax: --generate_rdoc, --install-missing [do export...gem update for straight updates, too...]'
raise unless ARGV[0] if $0 == __FILE__
# note: I only do this on the ilab, then rsync over...

ENV['GEM_PATH'] = '/home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/1.8'

bin_dir = '/home/rdp/dev/linode/installs/mbari_gembox_187/bin'
generate_rdoc = ARGV[0] == '--generate_rdoc'

require 'pp'

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
      puts 'here1' + line
      line =~ /(.*) \((.*)\)/
      next unless $1 # first few lines are bunk [?] necessary?
      name = $1.strip # strip just in case...
      versions = $2
      versions = versions.split(', ')
      all_gems[name] = versions.sort.last # latest one...
   }
   return all_gems
end

if generate_rdoc
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
else
   all = `gem list -r` # we don't do gems.github.com yet
   # gem list -r --source http://gems.github.com
   # command = "gem install #{name} --version=#{versions.sort.last} --no-rdoc --no-ri"
   # just in case system(command)
end if $0 == __FILE__
