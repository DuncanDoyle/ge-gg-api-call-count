#!/bin/sh

printf "\nTailing the Gloo Edge Envoy access logs.\n"

export DATE=$(date +%Y-%m-%d_%H-%M-%S)

export LOG_FILE_NAME="ge-api-call-count-jmeter-test-$DATE.log"

printf "\nLogging to file: $LOG_FILE_NAME\n"


GATEWAY_PROXY=$(kubectl get -A pods --selector=gloo=gateway-proxy -o jsonpath='{.items[*].metadata.name}')

GATEWAY_PROXY_NAMESPACE=$(kubectl get -A pods --selector=gloo=gateway-proxy -o jsonpath='{.items[*].metadata.namespace}')

kubectl -n $GATEWAY_PROXY_NAMESPACE logs --tail=0 -f $GATEWAY_PROXY | grep "HTTP/1.1" > $LOG_FILE_NAME
