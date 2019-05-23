#!/bin/sh
set -xue
set -o pipefail

#export VERSION=$(git describe --tags --always --dirty)  --- fail because git is not installed in runner image


docker pull $CI_REGISTRY_IMAGE:$VERSION
docker build --pull \
    --cache-from=$CI_REGISTRY_IMAGE:$VERSION \
    -t $CI_REGISTRY_IMAGE:run-$VERSION \
    --target run  .
docker push $CI_REGISTRY_IMAGE:run-$VERSION
