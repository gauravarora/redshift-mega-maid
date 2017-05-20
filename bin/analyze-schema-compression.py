#!/bin/bash
#
#                                 Apache License
#   Copyright 2016 ReturnPath
#   Copyright 2016 James Cuzella
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
##
## Note: This Docker container and script only automate installation & wrap
##       the original tools released as: "awslabs/amazon-redshift-utils"
##       The source code distributed in this repo is under the Apache License,
##       while the source code provided by Amazon is distributed under the
##       "Amazon Software License": http:aws.amazon.com/asl/

python /opt/amazon-redshift-utils/src/ColumnEncodingUtility/analyze-schema-compression.py \
       --db $MM_DB_NAME --db-user $MM_DB_USER --db-pwd $MM_DB_PASS \
       --db-port $MM_DB_PORT --db-host $MM_DB_HOST \
       --analyze-schema  $MM_DB_SCHEMA \
       --output-file $MM_OUTPUT_FILE --debug $MM_DEBUG \
       --ignore-errors $MM_IGNORE_ERRORS --slot-count $MM_SLOT_COUNT \
       --min-unsorted-pct $MM_MIN_UNSORTED_PCT --max-unsorted-pct $MM_MAX_UNSORTED_PCT \
       --deleted-pct $MM_DELETED_PCT --stats-off-pct $MM_STATS_OFF_PCT --max-table-size-mb $MM_MAX_TABLE_SIZE_MB
