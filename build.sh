#!/bin/bash

IMAGE=firestorm_build_env_ubuntu_16.04
IMAGE_VERSION=0.2.2

WIN_VOLUME=firestorm_build_env_volume


ENTRY_SCRIPT=src/entry.sh


pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


if ! docker volume inspect "$IMAGE:$IMAGE_VERSION" > /dev/null 2>&1
then
    echo "Building new docker image \"$IMAGE:$IMAGE_VERSION\" ..."
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
       ENTER_TO_SHELL=true
       ;;
    ?) 
       echo "error: option -$OPTARG is not implemented."
       exit 2 
       popd
       ;;
    esac
done


if type "winpty" > /dev/null 2>&1
then
    WINPTY=winpty
fi


if [ "$ON_WINDOWS" = true ]
then
    if ! docker volume inspect "$WIN_VOLUME" > /dev/null 2>&1
    then
        echo "Creating new named docker volume \"$WIN_VOLUME\" for build environment."
        docker volume create "$WIN_VOLUME"
    fi
    
    mkdir -p "artifacts"
    
    # Default to -ti, unless not supported
    
    INTERACTIVE_FLAG=-ti
    
    if [ "$WINPTY" = winpty ]
    then 
        # The path in the container needs an extra slash at the front when
        # docker is run via winpty, to keep it from trying to resolve to a path
        # local to the host.
        CONTAINER_MNT_SLASH=/
        
        # Add a slash in front to prevent weird directory resolution behavior
        # caused by winpty
        ABSOLUTE_HOST_MNT_ROOT="/$PWD/"
    else
    
        # -ti cannot work in win bash without something like winpty
        # cygwin does not come with it by default, but git-bash does.
        
        INTERACTIVE_FLAG=-i
    
        # No mount path hacks required without winpty
        
        ABSOLUTE_HOST_MNT_ROOT="$WIN_PWD\\"
    fi

    $WINPTY docker run $INTERACTIVE_FLAG \
    --network=host \
    -e ON_WINDOWS=true \
    -e ENTER_TO_SHELL=$ENTER_TO_SHELL \
    -v "$WIN_VOLUME"://home/build \
    -v "${ABSOLUTE_HOST_MNT_ROOT}src":${CONTAINER_MNT_SLASH}/home/build/src \
    -v "${ABSOLUTE_HOST_MNT_ROOT}artifacts":${CONTAINER_MNT_SLASH}/home/build/artifacts \
    -v "${ABSOLUTE_HOST_MNT_ROOT}config":${CONTAINER_MNT_SLASH}/home/build/config \
    $IMAGE:$IMAGE_VERSION $ENTRY_SCRIPT
    
else

    docker run -ti \
    -e ON_WINDOWS=false \
    -e ENTER_TO_SHELL=$ENTER_TO_SHELL \
    -e LOCAL_USER_ID=`id -u $USER` \
    -e LOCAL_USER="$USER" \
    -v "$PWD/install.cache":"/var/tmp/$USER/install.cache" \
    -v "$PWD":"/home/build" $IMAGE:$IMAGE_VERSION $ENTRY_SCRIPT
    
fi

popd
