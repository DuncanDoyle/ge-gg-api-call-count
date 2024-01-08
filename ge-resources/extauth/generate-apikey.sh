#!/bin/sh

glooctl create secret apikey generated-apikey \
    --apikey-generate \
    --apikey-labels team=infrastructure

