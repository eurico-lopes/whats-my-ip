#!/bin/bash
set -e

docker build --target=test -t local-tests -f ../Dockerfile ../.
docker run local-tests