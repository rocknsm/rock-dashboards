#!/bin/bash

_URL=$1
KIBANA_URL=${_URL:=http://127.0.0.1:5601}
KIBANA_VERSION=$(curl -sI ${KIBANA_URL} | awk '/kbn-version/ { print $2 }')

updated=0
created=0
failed=0

echo "Please be patient as we import 200+ custom dashboards, visualizations, and searches..."

for item in config index-pattern search visualization dashboard url map canvas-workpad canvas-element timelion; do
  cd ${item} 2>/dev/null || continue

  for id in $(cat index.json | jq -r '.[]'); do
    file="${id}.ndjson"
    if curl -sI "${KIBANA_URL}/api/saved_objects/${item}/${id}" | grep -q '^HTTP.*404'; then
      # object doesn't exist, create it
      echo "Creating ${item} with id ${id}" > /dev/stderr
      response=$(
        curl -s -XPOST \
          "${KIBANA_URL}/api/saved_objects/_import" \
          -H "kbn-xsrf: true" \
          --form file=@"${file}"
      )
      result=$(echo "${response}" | jq -r '.success')
      if [[ "${result}" == "true" ]]; then
        created=$((created+1))
      else
        failed=$((failed+1))
        echo -e "Failed creating ${item} named ${file}: \n ${response}\n"
      fi
    else
      # object already exists, apply update
      echo "Overwriting ${item} named ${id}" > /dev/stderr
      response=$(
        curl -s -XPOST \
          "${KIBANA_URL}/api/saved_objects/_import?overwrite=true" \
          -H "kbn-xsrf: true" \
          --form file=@"${file}"
      )
      result=$(echo "${response}" | jq -r '.success')
      if [[ ${result} == "true" ]]; then
        updated=$((updated+1))
      else
        failed=$((failed+1))
        echo -e "Failed updating ${item} named ${file}: \n ${response}\n"
      fi

    fi
  done
  cd ..
done

# Set default index
defaultIndex=$(jq -r '.userValue' index-pattern/default.json)

echo "Setting defaultIndex to ${defaultIndex}" > /dev/stderr
curl -s -XPOST -H"kbn-xsrf: true" -H"Content-Type: application/json" \
  "${KIBANA_URL}/api/kibana/settings/defaultIndex" -d"{\"value\": \"${defaultIndex}\"}" >/dev/null

echo "Created: ${created}"
echo "Updated: ${updated}"
echo "Failed: ${failed}"