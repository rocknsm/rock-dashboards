#!/bin/bash

_URL=$1
KIBANA_URL=${_URL:=http://127.0.0.1:5601}
KIBANA_VERSION=$(curl -sI ${KIBANA_URL} | awk '/kbn-version/ { print $2 }')

for item in index-pattern search visualization dashboard config; do
    cd ${item} 2>/dev/null || continue

    for id in $(cat index.json | jq -r '.[]'); do
        if curl -sI "${KIBANA_URL}/api/saved_objects/${item}/${id}" | grep -q '^HTTP.*404'; then
            # object doesn't exist, create it
            echo "Creating ${item} with id ${id}" > /dev/stderr
            curl -s -XPOST \
                -H"kbn-xsrf: true" \
                -H"Content-Type: application/json" \
                "${KIBANA_URL}/api/saved_objects/${item}/${id}" \
                -d"{\"attributes\": $(cat ${id}.json | jq '.attributes'),\"references\": $(cat ${id}.json | jq '.references')}" > /dev/null
        else
            # object already exists, apply update
            echo "Overwriting ${item} named ${id}" > /dev/stderr
            curl -s -XPUT \
                -H"kbn-xsrf: true" \
                -H"Content-Type: application/json" \
                "${KIBANA_URL}/api/saved_objects/${item}/${id}?overwrite=true" \
                -d"{\"attributes\": $(cat ${id}.json | jq '.attributes'),\"references\": $(cat ${id}.json | jq '.references')}" > /dev/null
        fi
    done
    cd ..
done

# Set default index
defaultIndex=$(jq -r '.userValue' index-pattern/default.json)

echo "Setting defaultIndex to ${defaultIndex}" > /dev/stderr
curl -s -XPOST -H"kbn-xsrf: true" -H"Content-Type: application/json" \
    "${KIBANA_URL}/api/kibana/settings/defaultIndex" -d"{\"value\": \"${defaultIndex}\"}" >/dev/null
