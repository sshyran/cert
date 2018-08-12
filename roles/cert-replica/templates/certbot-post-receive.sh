#!/bin/bash
LOG=/var/log/letsencrypt/letsencrypt.log
echo "$(date): start post-push actions" >> $LOG

# move temporary files to /etc/letsencrypt
(
    cd ~{{ certbot_replica_user }}
    chown -R root:root .letsencrypt.tmp
    for subdir in archive live ; do
        rsync -a --delete \
              .letsencrypt.tmp/$subdir/ \
              /etc/letsencrypt/$subdir/
        # fix directory permissions
        chown root:{{ certbot_group }} /etc/letsencrypt/$subdir
        chmod 0750 /etc/letsencrypt/$subdir
    done
    rm -rf .letsencrypt.tmp
) >> $LOG 2>&1

# run hook scripts
for script in /etc/letsencrypt/renewal-hooks/{pre,deploy,post}/*
do
    if [ -x $script ]; then
        echo "$(date): running $script"
        $script
    fi
done  >> $LOG 2>&1

# final message
echo "$(date): pushed successfully" >> $LOG
echo "pushed successfully"
