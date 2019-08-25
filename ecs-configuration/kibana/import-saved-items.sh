#!/bin/bash 

_URL=$1
KIBANA_URL=${_URL:=http://127.0.0.1:5601}
KIBANA_VERSION=$(curl -sI ${KIBANA_URL} | awk '/kbn-version/ { print $2 }')

for item in index-pattern search visualization dashboard config; do
    cd ${item} 2>/dev/null || continue

    for file in *.json; do
        id=$(echo "${file}" | sed -r ' s/\.json$//')
        if curl -sI "${KIBANA_URL}/api/saved_objects/${item}/${id}" | grep -q '^HTTP.*404'; then
            # object doesn't exist, create it
            echo "Creating ${item} with id ${id}" > /dev/stderr
            curl -s -XPOST \
                "${KIBANA_URL}/api/saved_objects/${item}/${id}" \
                -H "kbn-xsrf: true" \
                -H "Content-Type: application/json" \
                -d "@-" \
                <<< "{\"attributes\": $(cat "${file}")}" > /dev/null
        else
            # object already exists, apply update
            echo "Overwriting ${item} named ${id}" > /dev/stderr
            curl -s -XPUT \
                "${KIBANA_URL}/api/saved_objects/${item}/${id}" \
                -H "kbn-xsrf: true" \
                -H "Content-Type: application/json" \
                -d "@-" \
                <<< "{\"attributes\": $(cat "${file}")}" > /dev/null
        fi
    done
    cd ..
done

# Set default index
#defaultIndex=$(jq -r '.value' index-pattern/ecs-all.json)
defaultIndex="ecs-all"

echo "Setting defaultIndex to ${defaultIndex}" > /dev/stderr
curl -s -XPOST -H"kbn-xsrf: true" -H"Content-Type: application/json" \
	"${KIBANA_URL}/api/kibana/settings/defaultIndex" -d"{\"value\": \"${defaultIndex}\"}" >/dev/null
