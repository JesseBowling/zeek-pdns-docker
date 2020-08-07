#!/bin/bash

SLEEP_TIME=${SLEEP_TIME:-15}

echo "`date` Sleeping for ${SLEEP_TIME} seconds waiting for db to start..."
sleep ${SLEEP_TIME}
/go/bin/bro-pdns web
