#!/bin/sh
set -xue
set -o pipefail

# https://andrewlock.net/caching-docker-layers-on-serverless-build-hosts-with-multi-stage-builds---target,-and---cache-from/
# https://medium.com/@gajus/making-docker-in-docker-builds-x2-faster-using-docker-cache-from-option-c01febd8ef84

docker pull $CI_REGISTRY_IMAGE:builder || true
docker build --target builder \
    --cache-from $CI_REGISTRY_IMAGE:builder \
    -t $CI_REGISTRY_IMAGE:builder .


docker pull $CI_REGISTRY_IMAGE:run || true
docker build --target run \
    --cache-from $CI_REGISTRY_IMAGE:builder \
    --cache-from $CI_REGISTRY_IMAGE:run \
    -t $CI_REGISTRY_IMAGE:run \
    .


docker pull $CI_REGISTRY_IMAGE:latest || true
docker build \
    --cache-from=$CI_REGISTRY_IMAGE:builder \
    --cache-from=$CI_REGISTRY_IMAGE:run \
    --cache-from=$CI_REGISTRY_IMAGE:latest \
    -t $CI_REGISTRY_IMAGE:latest \
    -t $CI_REGISTRY_IMAGE:$VERSION \
    .

# Push builder image to remote repository for next build
docker push $CI_REGISTRY_IMAGE:builder
docker push $CI_REGISTRY_IMAGE:run
docker push $CI_REGISTRY_IMAGE:latest
docker push $CI_REGISTRY_IMAGE:$VERSION


