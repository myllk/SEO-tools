#!/usr/bin/env bash

# cd to script path
cd "$(dirname "$0")"

# make sure between 4 and 6 args (inclusive)
if [[ "$#" -ne 6 ]]; then
  echo "Usage: $0 {search string} {dd api key} {dd app key} {output file name} {from time} {to time}" >&2
  echo "Docs: https://docs.datadoghq.com/api/?lang=bash#get-a-list-of-logs"
  exit 1
fi

# arg parsing
echo "Args:"
SEARCH_STRING=$1
echo "SEARCH_STRING: ${SEARCH_STRING}"
DD_API_KEY=$2
echo "DD_API_KEY: ${DD_API_KEY}"
DD_APP_KEY=$3
echo "DD_APP_KEY: ${DD_APP_KEY}"
OUTPUT_FILE=$4
echo "OUTPUT_FILE: ${OUTPUT_FILE}"
FROM=$5
echo "FROM: ${FROM}"
TO=$6
echo "TO: ${TO}"

# dependencies
echo
echo "Testing dependencies"
curl --version
if [[ $? != "0" ]]; then
    echo "curl must be installed for this script to work" >&2
    echo "sudo apt-get install curl" >&2
    echo "sudo yum install curl" >&2
    exit 1
fi

jq --version
if [[ $? != "0" ]]; then
    echo "jq must be installed for this script to work" >&2
    echo "sudo pip install jq" >&2
    exit 1
fi

echo
echo "============================================================================================================================================================"
echo "WARNING: the default limit is 300 requests per hour (300,000 lines). Please make sure your query returns less than 300,000 lines in the Datadog log explorer"
echo "============================================================================================================================================================"

echo
echo "Getting log lines in blocks of 1000"
echo "Polling API..."
# send response
RESPONSE=$(curl -s -X POST \
    --header 'content-type: application/json' \
    --header "DD-API-KEY: ${DD_API_KEY}" \
    --header "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
    -d "{
            \"query\": \"${SEARCH_STRING}\",
            \"time\": {
                \"from\": \"${FROM}\",
                \"to\": \"${TO}\"
            },
            \"sort\": \"desc\",
            \"limit\": 1000
        }" \
    "https://api.datadoghq.com/api/v1/logs-queries/list")

# get status response
STATUS=$(echo ${RESPONSE} | jq -r '.status')
echo "REQUEST STATUS: ${STATUS}"
if [[ ${STATUS} != "done" ]]; then
    echo "Error in response JSON! Please investigate..."
    echo ${RESPONSE}
    exit 1
fi

# output log lines to file
echo ${RESPONSE} | jq -r '.logs[].content.message' >> "${OUTPUT_FILE}"

# get the next request ID
NEXT_LOG_ID=$(echo ${RESPONSE} | jq -r '.nextLogId')

# while there is another request ID to get (i.e. we've not fetched all the logs in the search)
while [[ ${NEXT_LOG_ID} != "null" ]]; do
    echo "Polling API..."
    # send response
    RESPONSE=$(curl -s -X POST \
        --header 'content-type: application/json' \
        --header "DD-API-KEY: ${DD_API_KEY}" \
        --header "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
        -d "{
                \"startAt\": \"${NEXT_LOG_ID}\",
                \"query\": \"${SEARCH_STRING}\",
                \"time\": {
                    \"from\": \"${FROM}\",
                    \"to\": \"${TO}\"
                },
                \"sort\": \"desc\",
                \"limit\": 1000
            }" \
        "https://api.datadoghq.com/api/v1/logs-queries/list")

    # get status response
    STATUS=$(echo ${RESPONSE} | jq -r '.status')
    echo "REQUEST STATUS: ${STATUS}"
    if [[ ${STATUS} != "done" ]]; then
        echo "Error in response JSON! Please investigate..."
        echo ${RESPONSE}
        exit 1
    fi

    # output log lines to file
    echo ${RESPONSE} | jq -r '.logs[].content.message' >> "${OUTPUT_FILE}"

    # get the next request ID
    NEXT_LOG_ID=$(echo ${RESPONSE} | jq -r '.nextLogId')
done

echo
echo "Done!"
