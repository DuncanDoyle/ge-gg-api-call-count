#!/bin/sh

####################################################################################
#
# Sets up Gloo Edge to run the JMeter test scripts.
#
# Requires an existing Gloo Edge 1.15+ setup with ExtAuth and RateLimiting.
# Requires the glooctl CLI to be installed.
#
####################################################################################

pushd ../ge-resources

# Apply the HTTPBin sevice
kubectl apply -f httpbin.yaml

# Setup ExtAuth and RateLimit configurations
kubectl apply -f extauth/auth-config.yaml
kubectl apply -f ratelimit/ratelimit-config.yaml

# Create the ApiKeys for the extauth and ratelimit test-runs
extauth/create-apikey.sh
extauth/create-apikey-for-ratelimit.sh

# Apply the VirtualService
kubectl apply -f vs.yaml

popd