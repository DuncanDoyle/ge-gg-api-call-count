#!/bin/sh

kubectl -n gloo-mesh-gateways port-forward deployment/istio-ingressgateway-1-20-1-patch1 15020:15020
