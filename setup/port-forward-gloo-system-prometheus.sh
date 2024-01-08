#!/bin/sh

kubectl -n gloo-system port-forward svc/glooe-prometheus-server 9090:80