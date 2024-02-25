#!/bin/bash
# Updated script to backup PostgreSQL v10 databases and restore to a newer version,
# avoiding local settings issues.

echo "Setting source variables."
source_username=postgres@psql-master-northeu
source_host=psql-master-northeu.postgres.database.azure.com
production_database=eightysix_production

echo "Setting target variables."
read -p "Choose the target server. [dev/prod] " environment
if [ "$environment" == "prod" ]; then
    echo "Targeting the remote production server."
    target_username=postgres
    target_host=psql-master-northeu-001.postgres.database.azure.com
else
    echo "Targeting the local development server."
    target_username=postgres
    target_host=localhost
fi
read -p "Are you sure? [Y/N] " confirm
if [ "$confirm" != "Y" ]; then
    exit 1
fi

pipe_backup_and_restore_database() {
    echo "Recreating ${1} database on target server with specific locale and encoding."
    dropdb --if-exists --host=$target_host --username=$target_username $1

    # Specify the locale and encoding to ensure compatibility across versions
    # and avoid issues with local settings.
    createdb --host=$target_host --username=$target_username --encoding='UTF8' --locale='en_US.UTF-8' $1

    echo "Piping ${1} schema and data from source server to target server, ensuring version compatibility."
    pg_dump --format=custom --no-owner --no-acl --dbname=$1 --host=$source_host --username=$source_username \
    | pg_restore --format=custom --dbname=$1 --host=$target_host --username=$target_username

    echo "${1} database restoration complete."
}

echo "Running production database backup and restore."
pipe_backup_and_restore_database $production_database