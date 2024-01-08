#!/bin/sh

############################################################################################################
#
# Gets Prometheus metrics of the last 10 minutes (see the TIME_RANGE variable).
#
############################################################################################################

TIME_RANGE=10m

# Retrieves all the successful upstream requests .... This means that it doesn't include call that got denied because of ExtAuth, RateLimit and/or WAF.
# It might also not include requests that ended up in an error in upstream.
printf "\nCluster External Upstream RQ Completed: "
QUERY="sum(increase(envoy_cluster_external_upstream_rq_completed{job!~'.*monitoring-service|.*component-service|kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'

printf "\nCluster Upstream RQ completed: "
# QUERY="sum(increase(envoy_cluster_external_upstream_rq{job!~'kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
QUERY="sum(increase(envoy_cluster_upstream_rq_completed{job!~'.*monitoring-service|.*component-service|kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'


# Retrieves all the upstream request per envoy_cluster per response code. This included error responses from upstream, like 503s, 504s, etc.
printf "\nCluster External Upstream RQ (all response codes): "
# QUERY="sum(increase(envoy_cluster_external_upstream_rq{job!~'kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
# curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'
QUERY="increase(envoy_cluster_external_upstream_rq{job!~'.*monitoring-service|.*component-service|kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE])"
# Sort the reponse per response code.
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq -r '.data.result[] | .metric.envoy_cluster_name  + " - response code " + .metric.envoy_response_code + ": " + .value[1]'

# Retrieves all the upstream requests.
# It seems that this also includes the ExtAuth and Rate-Limited requests.
# Includes 200, 201, 202, 204, 401, 429, 503 and 504 response codes.
# What seems to be missing are the WAF filtered requests (the 418 codes) and the ExtAuth and RateLimit errors, resulting in 403s .....
printf "\nCluster Upstream RQ (all response codes): "
# QUERY="sum(increase(envoy_cluster_upstream_rq{job!~'kubernetes-pods',envoy_cluster_name!~'admin_port_cluster|extauth_gloo-system|rate-limit_gloo-system|xds_cluster'}[$TIME_RANGE]))"
# curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'
QUERY="increase(envoy_cluster_upstream_rq{job!~'kubernetes-pods',envoy_cluster_name!~'admin_port_cluster|extauth_gloo-system|rate-limit_gloo-system|xds_cluster'}[$TIME_RANGE])"
# Sort the reponse per response code.
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq -r '.data.result[] | .metric.envoy_cluster_name  + " - response code " + .metric.envoy_response_code + ": " + .value[1]'

# These are denied ext-auth requests, which would result in a 401.
printf "\nExtAuth Denied: "
QUERY="sum(increase(envoy_cluster_ext_authz_denied{job!~'kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'


# These are error ext-auth requests, which would probably result in a 403 ....
printf "\nExtAuth Error: "
QUERY="sum(increase(envoy_cluster_ext_authz_error{job!~'kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'


# These are queries that passed extauth.
printf "\nExtAuth OK: "
QUERY="sum(increase(envoy_cluster_ext_authz_ok{job!~'kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'


# These are queries that passed extauth.
# envoy_cluster_ratelimit_error{envoy_cluster_name="default-httpbin-8000_gloo-system"} 2258

printf "\nRateLimit Error: "
QUERY="sum(increase(envoy_cluster_ratelimit_error{job!~'kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'


printf "\nRateLimit Failure Mode Allowed: "
QUERY="sum(increase(envoy_cluster_ratelimit_failure_mode_allowed{job!~'kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'


printf "\nRateLimit OK: "
QUERY="sum(increase(envoy_cluster_ratelimit_ok{job!~'kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'


printf "\nRateLimit Over: "
QUERY="sum(increase(envoy_cluster_ratelimit_over_limit{job!~'kubernetes-pods',envoy_cluster_name!='admin_port_cluster'}[$TIME_RANGE]))"
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'



printf "\nTotal HTTP requests: "
# QUERY="sum(increase(envoy_http_req_total[$TIME_RANGE]))"
QUERY="sum(increase(envoy_http_rq_total{envoy_http_conn_manager_prefix='http',job!~'kubernetes-pods'}[$TIME_RANGE]))"
# curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'
curl -s -g "http://localhost:9090/api/v1/query?query=$QUERY" | jq '.data.result[0].value[1]'
