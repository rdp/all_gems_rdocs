# run this in a nohup
ruby /home/rdp/dev/all_gems_rdocs/sync_all_gems.rb  --install-missing

# sync docs, too
rsync -r /home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/*  rdp@faithpromotingstories.org:~/installs/mbari_gembox_187/lib/ruby/gems
# re start it
ssh rdp@faithpromotingstories.org "touch ~/prod/gembox/tmp/restart.txt"
curl http://allgems.faithpromotingstories.org/gems 2>&1 > /dev/null
echo 'should be actualized now'
echo `date`
