#!/bin/bash
NAME=$1
LOG=/var/log/letsencrypt/letsencrypt.log

[ -n "$NAME" ] || exit 1
echo "$(date): start pushing to $NAME" >> $LOG

SUCCESS=$(
    (
        rsync -az --delete \
              /etc/letsencrypt/ \
              $NAME.certbot-replica:.letsencrypt.tmp/ &&

        ssh $NAME.certbot-replica \
            sudo /usr/local/sbin/certbot-post-receive.sh
    ) 2>&1 \
    | tee -a $LOG \
    | tail -2 | grep "pushed successfully" \
    | wc -l
)

if [ x"$SUCCESS" = x"1" ]; then
    echo "$(date): stop my own timer $NAME"
    systemctl stop certbot-push@$NAME.timer
fi >> $LOG 2>&1

echo "$(date): done pushing to $NAME" >> $LOG
