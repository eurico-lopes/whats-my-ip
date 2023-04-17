#!/bin/bash
set -e

DEFAULT_TAG=$(sh get-tag.sh)
TAG=${TAG:=$DEFAULT_TAG}
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_ID" --password-stdin
docker build --target=production -t ${DOCKER_ID}/whats_my_ip:${TAG} -f ../Dockerfile ../.
docker push ${DOCKER_ID}/whats_my_ip:${TAG}
