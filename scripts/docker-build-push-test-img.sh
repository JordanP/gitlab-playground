#!/bin/sh
set -xue
set -o pipefail

# Try to populate the docker cache (https://pythonspeed.com/articles/faster-multi-stage-builds/)
docker pull $CONTAINER_RELEASE_IMG_WITHOUT_TAG:latest || true

echo "Building $CONTAINER_TEST_IMG_WITH_TAG"

docker build --pull -t $CONTAINER_TEST_IMG_WITH_TAG --build-arg VERSION=unknown .
docker push $CONTAINER_TEST_IMG_WITH_TAG


