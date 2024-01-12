#!/bin/sh

############################################################################################################
#
# Gets Prometheus metrics of the last 10 minutes (see the TIME_RANGE variable).
#
############################################################################################################

TIME_RANGE=10m

# Retrieves all the istio requests.
# It seems that this also includes the ExtAuth (401), Rate-Limited (429), WAF (418) rejected requests, as well as requests that result in 404s becuase of missing routes ..
# Includes 200, 201, 202, 204, 401, 404,418 and 429 response codes.
printf "\nIstio Requests total for ingress-gateway (all response codes): "

# Sort the reponse per response code.
QUERY="increase(istio_requests_total{pod_name=~'istio-ingressgateway.*'}[$TIME_RANGE])"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq -r '.data.result[] | .metric.destination_service + " - response code " + .metric.response_code + ": " + .value[1]'

printf "\nTotal HTTP requests: "
QUERY="sum(increase(istio_requests_total{pod_name=~'istio-ingressgateway.*'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'
