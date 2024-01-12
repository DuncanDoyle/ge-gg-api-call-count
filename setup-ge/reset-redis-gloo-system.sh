#!/bin/sh

####################################################################################
#
# Resets the ratelimit key in Redis. This allows us to run deterministic tests.
#
####################################################################################

# Get the Redis password
REDIS_PASSWORD=$(kubectl -n gloo-system exec -ti deployments/redis -c redis -- cat /redis-acl/redis-password)

# Get the keys in Rx
kubectl -n gloo-system exec -ti deployments/redis -c redis -- redis-cli -a "$REDIS_PASSWORD" KEYS "*"

printf "\nCleaning the full Redis cache using 'FLUSHDB'.\n"
# Use FLUSHDB to remove all keys from the current Redis environment (bit of a dangerous operation :p)
kubectl -n gloo-system exec -ti deployments/redis -c redis -- redis-cli -a "$REDIS_PASSWORD" FLUSHDB