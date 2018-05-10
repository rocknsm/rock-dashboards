#!/bin/bash 


_URL=$1
ES_URL=${_URL:='http://127.0.0.1:9200'}

for id in $(curl -s "${ES_URL}/_template" | jq -r 'keys[]' | grep -vE 'kibana|logstash'); do
    echo "Exporting template named ${id} as ${id}.json" > /dev/stderr
    curl -s "${ES_URL}/_template/${id}" | jq '.' > "${id}.json"
done

