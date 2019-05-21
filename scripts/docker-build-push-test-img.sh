#!/bin/sh
set -xue
set -o pipefail


echo "Building $CONTAINER_TEST_IMG_WITH_TAG"

docker build --pull -t $CONTAINER_TEST_IMG_WITH_TAG --build-arg VERSION=unknown .
docker push $CONTAINER_TEST_IMG_WITH_TAG


