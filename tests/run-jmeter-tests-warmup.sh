#!/bin/sh

############################################################################################################
#
# Will run our JMeter tests warmup and analyze the result.
#
############################################################################################################

printf "\nStarting JMeter tests warmup.\n"

export DATE=$(date +%Y-%m-%d_%H-%M-%S)

JMETER_TEST_LOG_FILE="ge-gg-api-call-count-test-warmup-result-$DATE.jtl"

jmeter -n -t ge-gg-api-call-count-warmup.jmx -l $JMETER_TEST_LOG_FILE

printf "\nStarting JMeter completed.\n"

printf "\nAnalyzing JMeter test results completed.\n"
./analyze-jmeter-results.sh $JMETER_TEST_LOG_FILE