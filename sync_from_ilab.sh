# this does docs, too
rsync -r /home/rdp/dev/linode/installs/mbari_gembox_187/lib/ruby/gems/*  rdp@faithpromotingstories.org:~/installs/mbari_gembox_187/lib/ruby/gems
ssh rdp@faithpromotingstories.org "touch ~/prod/gembox/tmp/restart.txt"
curl http://allgems.faithpromotingstories.org/gems > /dev/null # re-read it
