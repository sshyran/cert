#!/bin/bash
#set -x

NAME=$1
LOG="{{ certbot_log_file }}"
LEDIR="{{ certbot_dir }}"
LETEMP="{{ certbot_replica_tempdir }}"
HANDLER="{{ certbot_replica_handler }}"

[[ $NAME ]] || exit 1
echo "$(date -Iseconds): start pushing to ${NAME}" | tee -a "$LOG"

SUCCESS=$(
    (
        # shellcheck disable=SC2029
        rsync -z -a --delete \
              "$LEDIR"/ \
              "${NAME}.certbot-replica:${LETEMP}/" && \
        ssh "${NAME}.certbot-replica" \
            sudo "$HANDLER"
    ) 2>&1 \
    | tee -a "$LOG" \
    | tail -2 \
    | grep -c "pushed successfully"
)

if [[ $SUCCESS = 1 ]]; then
    echo "$(date -Iseconds): stop push-timer ${NAME}"
    systemctl stop "certbot-push@${NAME}.timer"
fi >> "$LOG" 2>&1

echo "$(date -Iseconds): done pushing to ${NAME}" | tee -a "$LOG"
