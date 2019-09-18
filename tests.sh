#!/bin/bash

set -e
shopt -s globstar

for i in **/*-test.jsonnet; do
    echo "$i"
    jsonnet "$i"
done
