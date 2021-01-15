#!/bin/bash
NAME=$1
LOG="{{ certbot_log_file }}"
LETEMP="{{ certbot_replica_tempdir }}"

[ -n "$NAME" ] || exit 1
echo "$(date): start pushing to $NAME" >> $LOG

SUCCESS=$(
    (
        rsync -z -a --delete \
              {{ certbot_dir }}/ \
              $NAME.certbot-replica:$LETEMP/ &&

        ssh $NAME.certbot-replica \
            sudo {{ certbot_replica_handler }}
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
