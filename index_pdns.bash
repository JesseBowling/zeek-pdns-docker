#!/bin/bash

BRO_DNS_FILES=${BRO_DNS_FILES:-/data/logs}
SLEEP_TIME=${SLEEP_TIME:-3600}

echo "`date` Sleeping for 30 seconds waiting for containers to start..."
sleep 30

while true
do
  echo "`date` Starting search for new files..."
  for FILE in `find ${BRO_DNS_FILES} -name dns*|sort -n 2>/dev/null`
  do
    echo "`date` Starting to ingest ${FILE}"
    /go/bin/bro-pdns index ${FILE}
    if [[ $? == 0 ]]
    then
      echo "`date` Finished indexing file ${FILE} successfully"
    else
      echo "`date` Did not successfully index ${FILE}...skipping for now"
    fi
  done
  echo "`date` Done with all found files...Sleeping for ${SLEEP_TIME}"
  sleep ${SLEEP_TIME}
done
