#!/bin/bash

_URL=$1
KIBANA_URL=${_URL:=http://127.0.0.1:5601}

for item in config index-pattern search visualization dashboard url map canvas-workpad canvas-element timelion; do
  mkdir -p ${item}
  cd ${item}

  export FIRST=1
  echo -n "[" > index.json
  for id in $(curl -s "${KIBANA_URL}/api/saved_objects/_find?type=${item}&per_page=1000" | jq -r '.saved_objects[] | .id'); do
    file="${id}.ndjson"
    if [ "x${FIRST}" == "x0" ]; then
      echo -n ", " >> index.json
    else
      export FIRST=0
    fi

    echo "Exporting ${item} named ${id} as ${file}" > /dev/stderr
    curl -s -XPOST \
      "${KIBANA_URL}/api/saved_objects/_export" \
      -H "kbn-xsrf: true" \
      -H "Content-Type: application/json" \
      -d"
        { \"objects\": [
            {
              \"type\": \"${item}\",
              \"id\": \"${id}\",
              \"excludeExportDetails\": false
            }
        ] }
      " \
      > "${file}"
    echo -n "\"${id}\"" >> index.json

    done
    echo -n "]" >> index.json

    # Sort index for idempotence
    jq '. | sort' < index.json > index2.json && mv index2.json index.json
    unset FIRST

    cd ..
done

# Save default index
echo "Exporting default index pattern setting."
curl -s "${KIBANA_URL}/api/kibana/settings" | jq '.settings.defaultIndex' > index-pattern/default.json