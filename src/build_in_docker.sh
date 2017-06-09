#!/bin/bash

cd ~

source config/viewer.conf

if [ ! -d "firestorm-source" ]
then
    echo "Cloning firestorm repo, please wait..."

    hg clone $FIRESTORM_REPO firestorm-source
    if [ $? -ne 0 ]
    then
        echo "Failed to clone firestorm repo! exiting."
        exit 1
    fi
        
fi

cd ~/firestorm-source

hg up $FIRESTORM_REPO_TAG
if [ $? -ne 0 ]
then
    echo "Could not checkout repo tag: $FIRESTORM_REPO_TAG, exiting."
    exit 1
fi

if [ ! -d "3p-fmodex" ]
then
    echo "Cloning 3p-fmodex repo, please wait..."

    if hg clone https://bitbucket.org/NickyD/3p-fmodex
    then
        cd 3p-fmodex
    else
        echo "Failed to clone 3p-fmodex repo! exiting."
        exit 1
    fi

    # Monkey patch.  Download the FMod-Ex tar from a local directory
    # instead of the internal IP hardcoded into the original script
    yes | cp ~/src/fmodex-build-cmd.sh ./build-cmd.sh

    autobuild build --all --id "$FMODEX_AUTOBUILD_BUILD_ID"

    if [ $? -ne 0 ]
    then
        echo "3p-fmodex: autobuild --all, failed! exiting."
        exit 1
    fi

    autobuild package

    if [ $? -ne 0 ]
    then
        echo "3p-fmodex: autobuild package, failed! exiting."
        exit 1
    fi

    cd ..
fi


FMOD_MD5=$(md5sum 3p-fmodex/fmodex*.tar.bz2 | awk '{ print $1 }')
FMOD_PLATFORM=linux
FMOD_URL="file://$HOME/firestorm-source/$(echo 3p-fmodex/fmodex*.tar.bz2)"


echo FMOD_PLATFORM $FMOD_PLATFORM
echo FMOD_MD5 $FMOD_MD5
echo FMOD_URL $FMOD_URL


cp autobuild.xml docker_autobuild.xml

export AUTOBUILD_CONFIG_FILE=docker_autobuild.xml


autobuild installables edit fmodex platform="$FMOD_PLATFORM" hash="$FMOD_MD5" url="$FMOD_URL"

build_firestorm

if [ $? -ne 0 ]
then
    echo "firestorm-source: build failed! exiting."
    exit 1
fi

# Copy the artifacts folder out to the host mapped "artifacts" folder on windows

if [ "$ON_WINDOWS" = true ]
then
    echo "Copying build artifacts to host mapped volume \"artifacts\", please wait..."
    for i in ~/firestorm-source/build-linux-x86_64/newview/*.tar.xz; do /bin/cp "$i" ~/artifacts/; done
    echo "Done copying build artifacts."
fi


