#!/bin/bash

pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE_VERSION=0.1.0

if [[ "$(docker images -q firestorm_build_env_ubuntu_16.04:$IMAGE_VERSION 2> /dev/null)" == "" ]]
then
	docker build --tag firestorm_build_env_ubuntu_16.04:$IMAGE_VERSION
fi

docker run -v ${PWD}:/home/fs_build firestorm_build_env_ubuntu_16.04:$IMAGE_VERSION \
bash /home/fs_build/src/build_in_docker.sh

popd
