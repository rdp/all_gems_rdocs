# sync docs, too
mkdir -p  /home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby
rsync -r  rdp@allgems.ruby-forum.com:~/installs/mbari_gembox_187/lib/ruby/gems /home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby
echo 'got em maybe'
echo `date`
