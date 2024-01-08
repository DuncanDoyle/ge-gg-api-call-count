#!/bin/sh

kubectl -n gloo-system port-forward deployment/gateway-proxy 8081:8081