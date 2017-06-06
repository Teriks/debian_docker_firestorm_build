#!/bin/bash

cd /home/fs_build

source viewer.conf

if [ ! -d "firestorm-source" ]
then
	echo "Cloning firestorm repo, please wait..."

	hg clone $FIRESTORM_REPO firestorm-source
fi

cd /home/fs_build/firestorm-source

hg up $FIRESTORM_REPO_TAG

if [ ! -d "3p-fmodex" ]
then
        echo "Cloning 3p-fmodex repo, please wait..."

	hg clone https://bitbucket.org/NickyD/3p-fmodex
	cd 3p-fmodex

        # Monkey patch.  Download the FMod-Ex tar from a local directory
        # instead of the internal IP hardcoded into the original script
	yes | cp ../../src/fmodex-build-cmd.sh ./build-cmd.sh

        autobuild build --all
	autobuild package

	cd ..
fi


FMOD_MD5=$(md5sum 3p-fmodex/fmodex*.tar.bz2 | awk '{ print $1 }')
FMOD_PLATFORM=linux
FMOD_URL="file:///home/fs_build/firestorm-source/$(echo 3p-fmodex/fmodex*.tar.bz2)"


echo FMOD_PLATFORM $FMOD_PLATFORM
echo FMOD_MD5 $FMOD_MD5
echo FMOD_URL $FMOD_URL


cp autobuild.xml my_autobuild.xml
set AUTOBUILD_CONFIG_FILE=my_autobuild.xml


autobuild installables edit fmodex platform="$FMOD_PLATFORM" hash="$FMOD_MD5" url="$FMOD_URL"

autobuild -m64 configure -c ReleaseFS_open -- --chan $VIEWER_CHANNEL --package --fmodex $AUTOBUILD_EXTRA_OPTS

autobuild -m64 build -c ReleaseFS_open --no-configure




