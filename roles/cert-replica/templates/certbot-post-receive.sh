#!/bin/bash
#set -x

LESUBDIRS="archive live"
LOG="{{ certbot_log_dir }}/letsencrypt.log"
LEDIR="{{ certbot_dir }}"
LEHOOKD="{{ certbot_hook_dir }}"
LEGROUP="{{ certbot_group }}"
LETEMP="{{ certbot_replica_tempdir }}"
# shellcheck disable=SC1083
LEHOME=~{{ certbot_replica_user }}

# shellcheck disable=SC2129
echo "$(date -Iseconds): start post-push actions" >> "$LOG"

# move temporary files to {{ certbot_dir }}
if [ -d "${LEHOME}/${LETEMP}" ]
then
    MSG="syncing ${LETEMP}"
    echo "$(date -Iseconds): $MSG"
    cd "$LEHOME" || exit 1
    chown -R root:root "$LETEMP"
    for subdir in $LESUBDIRS
    do
        rsync -a --delete \
              "${LETEMP}/${subdir}/" \
              "${LEDIR}/${subdir}/"
    done
    rm -rf "$LETEMP"
else
    MSG="missing ${LETEMP}"
    echo "$(date -Iseconds): ${MSG}"
fi >> "$LOG" 2>&1

(
    # fix permissions on letsencrypt certificate directories
    chown "root:${LEGROUP}" "$LEDIR"/{archive,live}
    chmod 0750 "$LEDIR"/{archive,live}

    # fix permissions on letsencrypt private keys
    # shellcheck disable=SC2038
    find "${LEDIR}/archive" -name "privkey*.pem" \
         | xargs --no-run-if-empty chgrp "$LEGROUP"
    # shellcheck disable=SC2038
    find "${LEDIR}/archive" -name "privkey*.pem" \
         | xargs --no-run-if-empty chmod o=
) >> "$LOG" 2>&1

# run hook scripts
for script in "$LEHOOKD"/{pre,deploy,post}/*
do
    if [ -x "$script" ]; then
        echo "$(date -Iseconds): running ${script}"
        "$script"
    fi
done  >> "$LOG" 2>&1

# final message
echo "$(date -Iseconds): pushed successfully (slave ${MSG})" | tee -a "$LOG"
