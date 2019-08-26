#!/bin/bash

_URL=$1
KIBANA_URL=${_URL:=http://127.0.0.1:5601}
KIBANA_VERSION=$(curl -sI ${KIBANA_URL} | awk '/kbn-version/ { print $2 }')

cd config || exit
for id in $(cat index.json | jq -r '.[]'); do
  file="${id}.ndjson"
  echo "Setting kibana advanced settings" > /dev/stderr
  kibana_attributes=$(< "${file}" jq -r '.attributes')
  #echo "${kibana_attributes}"
  response=$(
    curl -s -XPOST \
      "${KIBANA_URL}/api/kibana/settings" \
      -H "kbn-xsrf: true" \
      -H "Content-Type: application/json" \
      -d "@-" \
      <<< "{ \"changes\": ${kibana_attributes} }"
  )
  echo "${response}"
done
cd ..