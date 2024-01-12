#!/bin/sh

kubectl -n gloo-mesh port-forward svc/prometheus-server 9090:80