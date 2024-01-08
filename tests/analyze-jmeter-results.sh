#!/bin/sh

LOG_FILE=$1

# List of Thread Groups that we want to analyze. Notice that the last Thread Group is an empty string, which basically means we want to select all of them, 
# which we use to get the total number of requests, response codes, etc. across threadgroups.
myThreadGroups=("HTTP Bin Thread Group - Default" "HTTP Bin Thread Group - No API Key" "HTTP Bin Thread Group - Rate Limited API-Key" "HTTP Bin Thread Group - WAF" "HTTP Bin Thread Group - 404 on Route" "HTTP Bin Thread Group - No Route" "")

# TODO: This script can probably be optimized by writing a temp file per thread-group, so we don't have the parse the full file for thread-group specific filtering.

# for THREAD_GROUP in $myThreadGroups
for THREAD_GROUP in "${myThreadGroups[@]}"
do
    if [ "$THREAD_GROUP" = "" ]; then
        printf "\nTotal\n"
    else 
        printf "\nThread Group: $THREAD_GROUP\n"
    fi

    # Print number of successful and unsucessful requests per thread group.

    TOTAL_REQUESTS=$(awk -F',' -v group="$THREAD_GROUP" 'NR>1 { if ($6 ~ group) { print $8} }' $1 | wc -l)
    SUCCESSFUL_REQUESTS=$(awk -F',' -v group="$THREAD_GROUP" 'NR>1 { if ($6 ~ group && $8 == "true") { print $8} }' $1 | wc -l)
    FAILED_REQUESTS=$(awk -F',' -v group="$THREAD_GROUP" 'NR>1 { if ($6 ~ group && $8 == "false") { print $8} }' $1 | wc -l)

    printf "\nTotal number of requests: $TOTAL_REQUESTS"
    printf "\nSuccessful requests: $SUCCESSFUL_REQUESTS"
    printf "\nFailed requests: $FAILED_REQUESTS"

    printf "\n\n"

    # Print number of results per response code.
    RESPONSE_CODES_LIST=$(awk -F',' -v group="$THREAD_GROUP" 'NR>1 { if ($6 ~ group) { print $4} }' $1 | sort | uniq)
    for RESPONSE_CODE in $RESPONSE_CODES_LIST
    do
        NUMBER_OF_CODES=$(awk -F',' -v group="$THREAD_GROUP" -v code="$RESPONSE_CODE" 'NR>1 { if ($6 ~ group &&  $4 == code) { print $4} }' $1 | wc -l)
   
        printf "Reponse code: $RESPONSE_CODE has $NUMBER_OF_CODES occurrences.\n"
        # or do whatever with individual element of the array
    done

    printf "\n\n-----------------------------------------------------------------------------------------------------------------------------------"
done


#Find the list of unique response codes.
printf "\n###################################################################################################################################\n"