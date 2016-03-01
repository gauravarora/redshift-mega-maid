#!/bin/bash

env

python /opt/amazon-redshift-utils/src/AnalyzeVacuumUtility/analyze-vacuum-schema.py \
       --db $MM_DB_NAME --db-user $MM_DB_USER --db-pwd $MM_DB_PASS \
       --db-port $MM_DB_PORT --db-host $MM_DB_HOST \
       --schema-name $MM_DB_SCHEMA --table-name $MM_DB_TABLE \
       --output-file $MM_OUTPUT_FILE --debug $MM_DEBUG \
       --ignore-errors $MM_IGNORE_ERRORS --slot-count $MM_SLOT_COUNT \
       --min-unsorted-pct $MM_MIN_UNSORTED_PCT --max-unsorted-pct $MM_MAX_UNSORTED_PCT \
       --deleted-pct $MM_DELETED_PCT --stats-off-pct $MM_STATS_OFF_PCT --max-table-size-mb $MM_MAX_TABLE_SIZE_MB

