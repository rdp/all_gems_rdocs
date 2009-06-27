# this does install and generate rdocs
# requires
#  cat ~/.gemrc
#  rdoc: --inline-source --line-numbers --format=html --template=hanna
#
if `hostname`.strip == "ilab1"
   puts 'on ilab'
   on_ilab = true
end

ENV['GEM_PATH'] = '/home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/1.8' if on_ilab
bin_dir = on_ilab ? '/home/rdp/dev/linode/installs/mbari_gembox_187/bin' : '.'
generate_rdoc = ARGV[0] == '--generate_rdoc'


if generate_rdoc
   all = `gem list`
else
   all = `gem list -r` # we don't do gems.github.com yet
end


all.each_line {|line|
   puts 'here1' + line
   line =~ /(.*) \((.*)\)/
   next unless $1 # first few lines are bunk [?] necessary?
   name = $1
   versions = $2
   versions = versions.split(', ')
   if generate_rdoc
      require 'rubygems' # pre load it, so fork works
      ARGV=['rdoc', name, '--no-ri']
      p 'ARGV is', ARGV
      Process.wait fork {
         load "#{bin_dir}/gem" # install rdocs appropo
      }
      puts 'here--done with gem' + name
   else
      # command = "gem install #{name} --version=#{versions.sort.last} --no-rdoc --no-ri"
      # just in case system(command)
   end

}
