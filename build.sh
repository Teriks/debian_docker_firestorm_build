#!/bin/bash

IMAGE=firestorm_build_env_ubuntu_16.04
IMAGE_VERSION=0.2.2

WIN_VOLUME=firestorm_build_env_volume


ENTRY_SCRIPT=src/entry.sh


pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


if [[ "$(docker images -q $IMAGE:$IMAGE_VERSION 2> /dev/null)" == "" ]]
then
    docker build --tag $IMAGE:$IMAGE_VERSION src
fi

case "$(uname -s)" in
    MINGW64*)
       ON_WINDOWS=true
       WIN_PWD=$(pwd -W)
       ;;
    CYGWIN*)
       ON_WINDOWS=true
       WIN_PWD=$(cygpath -w "$PWD")
       ;;
esac



while getopts ":i" option; do
    case $option in
    i) 
       INTERACTIVE_FLAG=-i
       INTERACTIVE=true
       ;;
    ?) echo "error: option -$OPTARG is not implemented"; exit ;;
    esac
done

if [ "$ON_WINDOWS" = true ]
then
    if ! docker volume inspect "$WIN_VOLUME" &> /dev/null
    then
        echo "Creating new named docker volume \"$WIN_VOLUME\" for build environment."
        docker volume create "$WIN_VOLUME"
    fi
    
    mkdir -p "artifacts"
    
    echo $IMAGE_HOME

    docker run $INTERACTIVE_FLAG \
    --network=host \
    -e ON_WINDOWS=true \
    -e INTERACTIVE=$INTERACTIVE \
    -v "$WIN_VOLUME":"/home/build" \
    -v "$WIN_PWD\\src":"/home/build/src" \
    -v "$WIN_PWD\\artifacts":"/home/build/artifacts" \
    -v "$WIN_PWD\\viewer.conf":"/home/build/viewer.conf" \
    $IMAGE:$IMAGE_VERSION $ENTRY_SCRIPT
else
    docker run $INTERACTIVE_FLAG \
    -e ON_WINDOWS=false \
    -e INTERACTIVE=$INTERACTIVE \
    -e LOCAL_USER_ID=`id -u $USER` \
    -e LOCAL_USER="$USER" \
    -v "$PWD/install.cache":"/var/tmp/$USER/install.cache" \
    -v "$PWD":"/home/build" $IMAGE:$IMAGE_VERSION $ENTRY_SCRIPT
fi

popd
