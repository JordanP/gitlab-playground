#!/bin/sh
set -xue
set -o pipefail

#export VERSION=$(git describe --tags --always --dirty)  --- fail because git is not installed in runner image

docker pull $CI_REGISTRY_IMAGE:build-$VERSION
docker pull $CI_REGISTRY_IMAGE:latest

docker build --pull \
    --cache-from=$CI_REGISTRY_IMAGE:build-$VERSION \
    --cache-from=$CI_REGISTRY_IMAGE:latest \
    -t $CI_REGISTRY_IMAGE:$VERSION \
    -t $CI_REGISTRY_IMAGE:latest \
    .

docker push $CI_REGISTRY_IMAGE:$VERSION
docker push $CI_REGISTRY_IMAGE:latest
