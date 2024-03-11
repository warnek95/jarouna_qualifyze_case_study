#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <comma-separated-list>"
    exit 1
fi

echo 'Starting saved_query_helper.sh'

dbt parse

IFS=',' read -ra files <<< "$1"

for file in "${files[@]}"; do
    echo "Processing: $file"
    mf query --saved-query $file --explain \
    | grep -v "Initiating query" \
    | grep -v "remove --explain" \
    > models/semantic_layer/saved_queries/$file.sql

    sed -i '' -E 's/"qualifyze"\.(.*)\."(.*)"/{{ ref("\2") }}/g' models/semantic_layer/saved_queries/$file.sql
    sed -i '' -E 's/"(.*)"\."(.*)"/{{ ref("\2") }}/g' models/semantic_layer/saved_queries/$file.sql
    sed -i '' -e '$ d' models/semantic_layer/saved_queries/$file.sql
done

echo 'Finished processing the saved queries'
