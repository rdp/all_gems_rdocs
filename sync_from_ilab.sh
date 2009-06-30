# run this in a nohup
ruby sync_all_gems.rb  --install-missing

# sync docs, too
rsync -r /home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/*  rdp@faithpromotingstories.org:~/installs/mbari_gembox_187/lib/ruby/gems
# re start it
ssh rdp@faithpromotingstories.org "touch ~/prod/gembox/tmp/restart.txt"
curl http://allgems.faithpromotingstories.org/gems > /dev/null
echo 'should be actualized now'
