#!/bin/bash

BRO_DNS_FILES=${BRO_DNS_FILES:-/data/logs}
BRO_SKIP_FILES=${BRO_SKIP_FILES:-/data/skipped}
SLEEP_TIME=${SLEEP_TIME:-60}

echo "`date` Sleeping for ${SLEEP_TIME} seconds waiting for containers to start..."
sleep ${SLEEP_TIME}

while true
do
  echo "`date` Starting search for new files..."
  for FILE in `ls ${BRO_DNS_FILES}/* 2>/dev/null`
  do
    echo "`date` Starting to ingest ${FILE}"
    /go/bin/bro-pdns index ${FILE}
    if [[ $? == 0 ]]
    then
      echo "`date` Finished indexing file ${FILE} successfully; deleting"
      rm ${FILE}
    else
      echo "`date` Did not successfully index ${FILE}...skipping removal"
      mv ${FILE} ${BRO_SKIP_FILES}
    fi
  done
  echo "`date` Done with all found files...Sleeping for ${SLEEP_TIME}"
  sleep ${SLEEP_TIME}
done
