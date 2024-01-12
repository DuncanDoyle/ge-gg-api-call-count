#!/bin/sh

####################################################################################
#
# Sets up Gloo Edge to run the JMeter test scripts.
#
# Requires an existing Gloo Edge 1.15+ setup with ExtAuth and RateLimiting.
# Requires the glooctl CLI to be installed.
#
####################################################################################

pushd ../gg-resources

# Apply the VirtualGateway
kubectl apply -f virtualgateways/vg.yaml

# Apply the HTTPBin sevice
kubectl apply -f apis/httpbin.yaml

# Setup ExtAuth and RateLimit configurations
kubectl apply -f policies/extauth/auth-server.yaml
kubectl apply -f policies/extauth/api-key-auth-policy.yaml

kubectl apply -f policies/ratelimit/rl-server.yaml
kubectl apply -f policies/ratelimit/rl-server-config.yaml
kubectl apply -f policies/ratelimit/rl-client-config-apikey.yaml
kubectl apply -f policies/ratelimit/rl-policy-apikey.yaml

kubectl apply -f policies/waf/waf-policy.yaml

# Create the ApiKeys for the extauth and ratelimit test-runs
kubectl apply -f policies/extauth/apikey.yaml
kubectl apply -f policies/extauth/apikey-for-ratelimit.yaml
kubectl apply -f policies/extauth/apikey-for-ratelimit-warmup.yaml

# Apply the routetable
kubectl apply -f routetables/httpbin-rt.yaml

popd