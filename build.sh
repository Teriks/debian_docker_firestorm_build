#!/bin/bash

pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE_VERSION=0.1.1

if [[ "$(docker images -q firestorm_build_env_ubuntu_16.04:$IMAGE_VERSION 2> /dev/null)" == "" ]]
then
	docker build --tag firestorm_build_env_ubuntu_16.04:$IMAGE_VERSION .
fi

docker run \
-e LOCAL_USER_ID=`id -u $USER` \
-e LOCAL_USER="$USER" \
-v ${PWD}:/home/fs_build firestorm_build_env_ubuntu_16.04:$IMAGE_VERSION \
bash /home/fs_build/src/entry.sh

popd
