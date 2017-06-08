#!/bin/bash

cd "$(dirname "$0")"

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

# Check autobuild is around or fail
if [ -z "$AUTOBUILD" ] ; then
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

# Load autobuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
set -x

# Form the official fmod archive URL to fetch
# Note: fmod is provided in 3 flavors (one per platform) of precompiled binaries. We do not have access to source code.
FMOD_ROOT_NAME="fmodapi"
FMOD_VERSION="44461"
URL_BASE="file://$HOME/src/"

case "$AUTOBUILD_PLATFORM" in
    "windows")
    FMOD_PLATFORM="win-installer"
    FMOD_PLATFORM_DIR="Win"
    FMOD_FILEEXTENSION=".exe"
    FMOD_MD5="b3a26243060bb9e8e1ac5e4c7e2a6427"
    ;;
    "darwin")
    FMOD_PLATFORM="mac-installer"
    FMOD_PLATFORM_DIR="Mac"
    FMOD_FILEEXTENSION=".dmg"
    FMOD_MD5="1620292499e01d7559591b5162cdd03d"
    ;;
    "linux")
    FMOD_PLATFORM="linux"
    FMOD_PLATFORM_DIR="Linux"
    FMOD_FILEEXTENSION=".tar.gz"
    FMOD_MD5="9f770e797c39192ff6cdb88dc05dd028"
    ;;
esac
FMOD_SOURCE_DIR="$FMOD_ROOT_NAME$FMOD_VERSION$FMOD_PLATFORM"
FMOD_ARCHIVE="$FMOD_SOURCE_DIR$FMOD_FILEEXTENSION"

# Fetch and extract the official fmod files
fetch_archive "$URL_BASE$FMOD_ARCHIVE" "$FMOD_ARCHIVE" "$FMOD_MD5"
# Workaround as extract does not handle .zip files (yet)
# TODO: move that logic to the appropriate autobuild script
case "$FMOD_ARCHIVE" in
    *.exe)
        7z x "$FMOD_ARCHIVE" -o"$FMOD_SOURCE_DIR"
    ;;
    *.tar.gz)
        extract "$FMOD_ARCHIVE"
    ;;
    *.dmg)
        hdid "$FMOD_ARCHIVE"
        mkdir -p "$(pwd)/$FMOD_SOURCE_DIR"
        cp -r /Volumes/FMOD\ Programmers\ API\ Mac/FMOD\ Programmers\ API/* "$FMOD_SOURCE_DIR"
        umount /Volumes/FMOD\ Programmers\ API\ Mac/
    ;;
esac

stage="$(pwd)/stage"
stage_release="$stage/lib/release"
stage_debug="$stage/lib/debug"

echo $FMOD_VERSION > "${stage}/VERSION.txt"

# Create the staging license folder
mkdir -p "$stage/LICENSES"

# Create the staging include folders
mkdir -p "$stage/include/fmodex"

#Create the staging debug and release folders
mkdir -p "$stage_debug"
mkdir -p "$stage_release"

pushd "$FMOD_SOURCE_DIR"
    case "$AUTOBUILD_PLATFORM" in
        "windows")
            # Copy relevant stuff around: renaming the import lib to make it easier on cmake
            cp "api/lib/fmodexL_vc.lib" "$stage_debug"
            cp "api/lib/fmodex_vc.lib" "$stage_release"
            cp "api/fmodexL.dll" "$stage_debug"
            cp "api/fmodex.dll" "$stage_release"

            cp "api/lib/fmodexL64_vc.lib" "$stage_debug"
            cp "api/lib/fmodex64_vc.lib" "$stage_release"
            cp "api/fmodexL64.dll" "$stage_debug"
            cp "api/fmodex64.dll" "$stage_release"

        ;;
        "darwin")
            cp "api/lib/libfmodexL.dylib" "$stage_debug"
            cp "api/lib/libfmodex.dylib" "$stage_release"
            pushd "$stage_debug"
              fix_dylib_id libfmodexL.dylib
            popd
            pushd "$stage_release"
              fix_dylib_id libfmodex.dylib
            popd
        ;;
        "linux")
            # Copy the relevant stuff around
            cp -a api/lib/libfmodexL-*.so "$stage_debug"
            cp -a api/lib/libfmodex-*.so "$stage_release"
            cp -a api/lib/libfmodexL.so "$stage_debug"
            cp -a api/lib/libfmodex.so "$stage_release"

            cp -a api/lib/libfmodexL64-*.so "$stage_debug"
            cp -a api/lib/libfmodex64-*.so "$stage_release"
            cp -a api/lib/libfmodexL64.so "$stage_debug"
            cp -a api/lib/libfmodex64.so "$stage_release"
        ;;    
    esac

    # Copy the headers
    cp -a api/inc/* "$stage/include/fmodex"

    # Copy License (extracted from the readme)
    cp "documentation/LICENSE.TXT" "$stage/LICENSES/fmodex.txt"
popd
pass


