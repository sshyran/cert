#!/bin/sh
# ansible-managed
# host: {{ inventory_hostname }}
# script: {{ certbot_post_dir }}/push
echo "$(date -Iseconds): start pushing to all replicas" >> "{{ certbot_log_file }}"
{% for host in certbot_master_replicas |sort %}
systemctl start certbot-push@{{ host }}.timer
{% endfor %}
