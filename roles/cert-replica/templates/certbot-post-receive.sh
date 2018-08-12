#!/bin/bash
LOG=/var/log/letsencrypt/letsencrypt.log
echo "$(date): start post-push actions" >> $LOG
# fix directory permission
chown root:{{ certbot_group }} /etc/letsencrypt/{archive,live}
chmod 0750 /etc/letsencrypt/{archive,live}
for script in /etc/letsencrypt/renewal-hooks/{pre,deploy,post}/*
do
    if [ -x $script ]; then
        echo "$(date): running $script" >> $LOG
        $script >> $LOG 2>&1
    fi
done
echo "$(date): pushed successfully" >> $LOG
echo "pushed successfully"
