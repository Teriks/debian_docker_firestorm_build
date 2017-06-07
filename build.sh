#!/bin/bash

pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE=firestorm_build_env_ubuntu_16.04
IMAGE_VERSION=0.2.1


if [[ "$(docker images -q $IMAGE:$IMAGE_VERSION 2> /dev/null)" == "" ]]
then
    docker build --tag $IMAGE:$IMAGE_VERSION src
fi

case "$(uname -s)" in
    MINGW64*)
       WIN_VOLUME=$(pwd -W)
       ;;
    CYGWIN*)
       WIN_VOLUME=$(cygpath -w "$PWD")
       ;;
esac

mkdir -p install.cache

if [ -n "${WIN_VOLUME+set}" ]
then
    docker run \
    -e ON_WINDOWS=true \
    -v "$WIN_VOLUME":/home/fs_build \
    -v "$WIN_VOLUME\\install.cache":/var/tmp/root/install.cache \
    $IMAGE:$IMAGE_VERSION src/entry.sh
else
    docker run \
    -e ON_WINDOWS=false \
    -e LOCAL_USER_ID=`id -u $USER` \
    -e LOCAL_USER="$USER" \
    -v "$PWD/install.cache":"/var/tmp/$USER/install.cache" \
    -v "$PWD":/home/fs_build $IMAGE:$IMAGE_VERSION src/entry.sh
fi

popd
