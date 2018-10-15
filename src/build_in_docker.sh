#!/bin/bash

export HOME=$BUILD_DIR
export CXXFLAGS=-Wno-error=misleading-indentation

cd ~

source config/build.conf

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

if [ ! -d "build-variables" ]
then
    echo "Cloning firestorm build-variables repo, please wait..."

    hg clone $FIRESTORM_BUILD_VARIABLES_REPO build-variables
    if [ $? -ne 0 ]
    then
        echo "Failed to clone firestorm build-variables repo! exiting."
        exit 1
    fi
fi


export AUTOBUILD_PLATFORM=linux64
export AUTOBUILD_VARIABLES_FILE=~/build-variables/variables
export AUTOBUILD_CONFIGURE_ARCH=$(arch)


cd ~/build-variables


hg up $FIRESTORM_BUILD_VARIABLES_REPO_TAG
if [ $? -ne 0 ]
then
    echo "Could not checkout firestorm build-variables repo tag: $FIRESTORM_BUILD_VARIABLES_REPO_TAG, exiting."
    exit 1
fi


cd ~/firestorm-source


hg up $FIRESTORM_REPO_TAG
if [ $? -ne 0 ]
then
    echo "Could not checkout firestorm repo tag: $FIRESTORM_REPO_TAG, exiting."
    exit 1
fi



if [ ! -d "3p-fmodstudio" ]
then
    echo "Cloning 3p-fmodstudio repo, please wait..."

    if hg clone https://bitbucket.org/Ansariel/3p-fmodstudio
    then
        cd 3p-fmodstudio
    else
        echo "Failed to clone 3p-fmodstudio repo! exiting."
        exit 1
    fi
    
    cp ~/src/fmodstudioapi*linux.tar.gz .

    # hack, this is used to extract the tar.
    # extract has a million dependencies and only this
    # functionality is ever used by the fmodstudio build script
    if [ ! -d "d_bin" ]
    then
        mkdir d_bin
        printf "#!/bin/bash\ntar -xvf \$@\n" > ./d_bin/extract
        chmod a+x ./d_bin/extract
    fi

    export PATH=$(pwd)/d_bin:$PATH

    autobuild build --all --id "$FMODSTUDIO_AUTOBUILD_BUILD_ID"

    if [ $? -ne 0 ]
    then
        echo "3p-fmodstudio: autobuild --all, failed! exiting."
        exit 1
    fi

    autobuild package

    if [ $? -ne 0 ]
    then
        echo "3p-fmodstudio: autobuild package, failed! exiting."
        exit 1
    fi

    cd ..
fi


FMOD_MD5=$(md5sum 3p-fmodstudio/fmodstudio*.tar.bz2 | awk '{ print $1 }')
FMOD_PLATFORM=$AUTOBUILD_PLATFORM
FMOD_URL="file://$HOME/firestorm-source/$(echo 3p-fmodstudio/fmodstudio*.tar.bz2)"


echo FMOD_PLATFORM $FMOD_PLATFORM
echo FMOD_MD5 $FMOD_MD5
echo FMOD_URL $FMOD_URL


cp autobuild.xml docker_autobuild.xml

export AUTOBUILD_CONFIG_FILE=docker_autobuild.xml

autobuild installables edit fmodstudio platform="$FMOD_PLATFORM" hash="$FMOD_MD5" url="$FMOD_URL"

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


