#!/bin/bash 

_URL=$1
KIBANA_URL=${_URL:=http://127.0.0.1:5601}

for item in index-pattern search visualization dashboard; do
    mkdir -p ${item}
    cd ${item}

    export FIRST=1 
    echo -n "[" > index.json
    for id in $(curl -s "${KIBANA_URL}/api/saved_objects/_find?type=${item}" | jq -r '.saved_objects[] | .id'); do
        if [ "x${FIRST}" == "x0" ]; then
            echo -n ", " >> index.json
        else
            export FIRST=0
        fi

        echo "Exporting ${item} named ${id} as ${id}.json" > /dev/stderr
        curl -s "${KIBANA_URL}/api/saved_objects/${item}/${id}" | jq  '.attributes' > "${id}.json"
        echo -n "\"${id}\"" >> index.json

    done
    echo -n "]" >> index.json
    unset FIRST

    cd ..
done

