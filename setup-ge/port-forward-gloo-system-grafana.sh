#!/bin/sh

kubectl -n gloo-system port-forward svc/glooe-grafana 3000:80