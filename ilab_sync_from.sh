# run this in a nohup
echo 'STARTING'
echo `date`
ruby /home/rdp/dev/all_gems_rdocs/sync_all_gems.rb  --install-missing
./just_sync.sh
