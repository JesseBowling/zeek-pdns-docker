#!/bin/bash
# https://github.com/kneufeld/minio-put/blob/master/minio-put.sh
# usage: ./minio-upload my-bucket my-file.zip

bucket=logs
file=$1

host=${FASTCHECK_HOST:-127.0.0.1}
s3_key=${FASTCHECK_KEY:-pdnslogs}
s3_secret=${FASTCHECK_SECRET:-KC6LRvwhNGfRrxA4JXZk}

base_file=`basename ${file}`
resource="/${bucket}/${base_file}"
content_type="application/octet-stream"
date=`date -R`
_signature="PUT\n\n${content_type}\n${date}\n${resource}"
signature=`echo -en ${_signature} | openssl sha1 -hmac ${s3_secret} -binary | base64`

curl -v -X PUT -T "${file}" \
          -H "Host: $host" \
          -H "Date: ${date}" \
          -H "Content-Type: ${content_type}" \
          -H "Authorization: AWS ${s3_key}:${signature}" \
          http://$host${resource}
