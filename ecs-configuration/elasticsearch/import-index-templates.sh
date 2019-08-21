#!/bin/bash

_URL=$1
ES_URL=${_URL:='http://127.0.0.1:9200'}

function is_integer() {
    [ "$1" -eq "$1" ] > /dev/null 2>&1
    return $?
}

changed=0
failed=0
ok=0

for item in *.json; do
  template_name=$(echo ${item} | sed -r ' s/\.json$//')
  version=$(cat ${item} | jq -r ".version")

  existing_version='-1'
  # Check if template already exists
  if curl -sI "${ES_URL}/_template/${template_name}" | grep -q "200 OK"; then
    existing_version=$(
      curl -s "${ES_URL}/_template/${template_name}?filter_path=*.version" | \
      jq -r ".version"
    )
    if ! is_integer ${existing_version}; then
      existing_version=-1
    fi
  fi

  if [[ "${version}" -gt "${existing_version}" ]]; then
    echo "Installing index mapping template: ${template_name} version ${version}" >/dev/stderr
    response=$(curl -s -XPUT "${ES_URL}/_template/${template_name}" -H "Content-Type: application/json" --data "@${item}")
    result=$(echo ${response} | jq -r '.acknowledged')
    if [ "${result}" == "true" ]; then
      changed=$[$changed + 1]
    else
      failed=$[$failed + 1]
      echo "Failed putting ${template_name} version ${version}: \n ${response}"
    fi
  else
    ok=$[$ok + 1]
  fi
done

echo "OK: ${ok}"
echo "Changed: ${changed}"
echo "Failed: ${failed}"