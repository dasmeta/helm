#!/bin/bash

env > /etc/environment

PORT=${MONGODB_PORT:-27017}
HOST=${MONGODB_HOST:-"localhost"}
AUTH_DB=${MONGODB_AUTH_DB:-"admin"}

MONGODB_USER=${MONGODB_INITDB_ROOT_USERNAME:-""}
MONGODB_PASS=${MONGODB_INITDB_ROOT_PASSWORD:-""}
MONGODB_DATABASE=${MONGODB_DATABASE:-""}
MONGODB_EXCLUDE_COLLECTIONS=${MONGODB_EXCLUDE_COLLECTIONS:-""}
BACKUP_CMD="mongodump --out /backup/"'${BACKUP_NAME}'" --gzip --host ${HOST} --port ${PORT} --authenticationDatabase ${AUTH_DB} ${EXTRA_OPTS}"

if [[ -n "${MONGODB_USER}" ]]; then
    BACKUP_CMD="${BACKUP_CMD}  --username ${MONGODB_USER}"
fi

if [[ -n "${MONGODB_PASS}" ]]; then
    BACKUP_CMD="${BACKUP_CMD}  --password ${MONGODB_PASS}"
fi

if [[ -n "${MONGODB_DATABASE}" ]]; then
    BACKUP_CMD="${BACKUP_CMD}  --db ${MONGODB_DATABASE}"
fi

if [[ -n "${MONGODB_EXCLUDE_COLLECTIONS}" ]]; then
    for COLLECTON in $(echo $MONGODB_EXCLUDE_COLLECTIONS | tr "," "\n")
    do
        BACKUP_CMD="${BACKUP_CMD} --excludeCollection ${COLLECTON}"
    done
fi

if [[ -n "${MONGODB_COLLECTIONS}" ]]; then
    for COLLECTON in $(echo $MONGODB_COLLECTIONS | tr "," "\n")
    do
        BACKUP_CMD="${BACKUP_CMD} --collection ${COLLECTON}"
    done
fi

rm -f /backup.sh
cat <<EOF >> /backup.sh
#!/bin/bash
MAX_BACKUPS=${MAX_BACKUPS:-"30"}
BACKUP_NAME=\$(date +\%Y.\%m.\%d.\%H\%M\%S)

echo "=> Backup started"
if ${BACKUP_CMD} ; then
    echo "   Backup succeeded"
else
    echo "   Backup failed"
    rm -rf /backup/\${BACKUP_NAME}
fi

if [ -n "\${MAX_BACKUPS}" ]; then
    while [ \$(ls /backup -N1 | wc -l) -gt \${MAX_BACKUPS} ];
    do
        BACKUP_TO_BE_DELETED=\$(ls /backup -N1 | sort | head -n 1)
        echo "   Deleting backup \${BACKUP_TO_BE_DELETED}"
        rm -rf /backup/\${BACKUP_TO_BE_DELETED}
    done
fi

if [ -n "\${S3_BUCKET}" ]; then
    echo "=> Starting Migration process..."
    source /migrate_backup_aws.sh
else
    echo "=> S3_BUCKET variable was not set, skipping migration"
    echo "=> Database backup was saved in /backup/\${BACKUP_NAME}"
fi
EOF

chmod +x /backup.sh
chmod +x /restore.sh
chmod +x /migrate_backup_aws.sh

touch /mongo_backup.log
# tail -F /mongo_backup.log &

if [[ "${INIT_BACKUP}" = true ]]; then
    echo "=> Creating a backup on startup"
    /backup.sh
fi

if [[ "${INIT_RESTORE}" = true ]]; then
    echo "=> Restoring the latest backup on startup"
    /restore.sh
fi

if [ "$RUN_AS_DAEMON" = true ]; then
    echo "${CRON_SCHEDULE} . /etc/environment; /backup.sh >> /mongo_backup.log 2>&1" > /crontab.conf
    #echo "${CRON_SCHEDULE} /migrate_backup_aws.sh >> /mongo_backup.log 2>&1" >> /crontab.conf
    crontab /crontab.conf
    echo "=> Running cron job"
    exec cron -f
else
    echo "=> Running backup job"
    /backup.sh
fi
