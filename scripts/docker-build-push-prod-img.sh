#!/bin/sh
set -xue
set -o pipefail

#export VERSION=$(git describe --tags --always --dirty)  --- fail because git is not installed in runner image
export VERSION=${CI_COMMIT_REF_SLUG}-${CI_COMMIT_SHORT_SHA}
echo "Tag: $VERSION"

docker pull $CONTAINER_TEST_IMG_WITH_TAG
docker build --pull -t $CONTAINER_RELEASE_IMG_WITHOUT_TAG:latest -t $CONTAINER_RELEASE_IMG_WITHOUT_TAG:$VERSION --target run --build-arg VERSION=$VERSION .
docker push $CONTAINER_RELEASE_IMG_WITHOUT_TAG:latest
docker push $CONTAINER_RELEASE_IMG_WITHOUT_TAG:$VERSION
