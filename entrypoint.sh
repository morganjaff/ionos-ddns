#!/bin/bash
set -e

CRON_SCHEDULE="${CRON_SCHEDULE:-*/5 * * * *}"

echo "$CRON_SCHEDULE /usr/local/bin/ionos_update.sh >> /var/log/ionos_update.log 2>&1" > /etc/crontabs/root

echo "$(date '+%Y-%m-%d %H:%M:%S') : [INFO] Cron configuré : $CRON_SCHEDULE"

# Première synchronisation immédiate au démarrage du conteneur
/usr/local/bin/ionos_update.sh

touch /var/log/ionos_update.log
crond -b -l 2
tail -f /var/log/ionos_update.log
