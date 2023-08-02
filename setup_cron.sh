#!/bin/bash

# Add cron jobs from a file (e.g., cronjobs.txt)
crontab  /root/cronjobs.txt

# Start the cron daemon
service cron start

# Keep the container running
tail -f /dev/null
