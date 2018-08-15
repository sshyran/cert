#!/bin/bash
LOG=/var/log/letsencrypt/letsencrypt.log
LEGROUP={{ certbot_group }}
LETEMP={{ certbot_replica_tempdir }}

echo "$(date): start post-push actions" >> $LOG

# move temporary files to /etc/letsencrypt
if [ -d ~{{ certbot_replica_user }}/$LETEMP ]
then
    echo "$(date): syncing $LETEMP"
    cd ~{{ certbot_replica_user }}
    chown -R root:root $LETEMP
    for subdir in archive live
    do
        rsync -a --delete \
              $LETEMP/$subdir/ \
              /etc/letsencrypt/$subdir/
    done
    rm -rf $LETEMP
else
    echo "$(date): missing $LETEMP"
fi >> $LOG 2>&1

(
    # fix permissions on letsencrypt certificate directories
    chown root:$LEGROUP /etc/letsencrypt/{archive,live}
    chmod 0750 /etc/letsencrypt/{archive,live}

    # fix permissions on letsencrypt private keys
    find /etc/letsencrypt/archive -name privkey*.pem \
         | xargs --no-run-if-empty chgrp $LEGROUP
    find /etc/letsencrypt/archive -name privkey*.pem \
         | xargs --no-run-if-empty chmod o=
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
