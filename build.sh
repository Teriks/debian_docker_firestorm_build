#!/bin/bash

pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE=firestorm_build_env_ubuntu_16.04
IMAGE_VERSION=0.1.2


if [[ "$(docker images -q firestorm_build_env_ubuntu_16.04:$IMAGE_VERSION 2> /dev/null)" == "" ]]
then
	docker build --tag $IMAGE:$IMAGE_VERSION .
fi

which cmd > /dev/null 2>&1
if [ $? -eq 0 ]
then
    case "$(uname -s)" in
        MINGW64*)
           VOLUME=$(pwd -W)
           ;;
        CYGWIN*)
           VOLUME=$(cygpath -w "$PWD")
           ;;
        *)
           echo "Unsupported version of windows bash! (MINGW64 and CYGWIN are supported), exiting."
           exit 1
           ;;
    esac

    docker run -i \
    -e ON_WINDOWS=true \
    -v $VOLUME:/home/fs_build $IMAGE:$IMAGE_VERSION bash src/entry.sh
else
    docker run -i \
    -e ON_WINDOWS=false \
    -e LOCAL_USER_ID=`id -u $USER` \
    -e LOCAL_USER="$USER" \
    -v $PWD:/home/fs_build $IMAGE:$IMAGE_VERSION bash src/entry.sh
fi

popd
