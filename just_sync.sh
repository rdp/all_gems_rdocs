# sync docs, too
rsync -r /home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/*  rdp@allgems.ruby-forum.com:~/installs/mbari_gembox_187/lib/ruby/gems
# re start it
ssh rdp@allgems.ruby-forum.com "touch ~/prod/gembox/tmp/restart.txt"
curl http://allgems.ruby-forum.com/gems > /dev/null
echo 'should be actualized now'
echo `date`
