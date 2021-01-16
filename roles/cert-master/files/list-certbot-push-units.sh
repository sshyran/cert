#!/bin/sh
systemctl list-units \
          --no-pager --no-legend \
          --all --type=service,timer \
          "certbot-push@*" \
          2>&1 | \
tr '@.' ',' | cut -d, -f2 | sort -u
