#!/bin/bash
# Script to backup PostgreSQL v10 databases for future restoration on a newer version,
# avoiding local settings issues.

echo "Setting source variables."
source_username=postgres@psql-master-northeu
source_host=psql-master-northeu.postgres.database.azure.com
production_database=eightysix_production

# Define backup file location and name
backup_directory=~/Documents/repos/database-migration
backup_filename="${production_database}_$(date +%Y-%m-%d_%H-%M-%S).bak"

echo "Starting backup of ${production_database} database."

# Ensure the backup directory exists
mkdir -p $backup_directory

# Perform the backup
pg_dump --format=custom --no-owner --no-acl --dbname=$production_database --host=$source_host --username=$source_username --file="${backup_directory}/${backup_filename}"

echo "Backup of ${production_database} completed and saved to ${backup_directory}/${backup_filename}"
