#!/bin/sh
set -xue
set -o pipefail

# https://andrewlock.net/caching-docker-layers-on-serverless-build-hosts-with-multi-stage-builds---target,-and---cache-from/
# https://medium.com/@gajus/making-docker-in-docker-builds-x2-faster-using-docker-cache-from-option-c01febd8ef84

docker pull $CI_REGISTRY_IMAGE:build-latest || true
docker build --target build \
    --cache-from $CI_REGISTRY_IMAGE:build-latest \
    -t $CI_REGISTRY_IMAGE:build-latest . \
    -t $CI_REGISTRY_IMAGE:build-$VERSION


# Push builder image to remote repository for next build
docker push $CI_REGISTRY_IMAGE:build-latest
docker push $CI_REGISTRY_IMAGE:build-$VERSION



