#!/bin/bash
DATE_SUBFIX=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/data/backup/pro/mysql_data/"
/opt/mysql/bin/mysqldump -P3306 -h127.0.0.1 -u root -pxxxxxx dbname --ignore-table=dbname.table1 --routines --events> ${BACKUP_DIR}/dbname_exclude_table1_${DATE_SUBFIX}.sql
