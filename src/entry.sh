#!/bin/bash

export HOME=/home/build

if [ "$INTERACTIVE" = true ]
then
    echo "=========================================="
    echo "Dropping into interactive container shell."
    echo "Current directory is: \"$PWD\"".
    echo "Leave with 'exit'."
    echo "=========================================="
    echo ""
    exec /bin/bash
fi


if [ "$ON_WINDOWS" = true ]
then
    # Resident to the container, build system reads cached dependencies from here
    mkdir /var/tmp/root
    
    # Make in the named volume if it does not exist
    mkdir -p "$HOME/install.cache"
    
    # Make the install.cache local to the volume by linking it, so it can be messed with from the interactive shell on windows and be persistant.
    ln -s "$HOME/install.cache" /var/tmp/root/install.cache
    
    # Windows does not care about volume permissions, just run the build
    exec "$HOME/src/build_in_docker.sh"
else
    
    USER_ID=${LOCAL_USER_ID:-9001}
    USER_NAME=${LOCAL_USER:-build_user}
    
    # /home/fs_build exists as a mounted volume, useradd warns that it exists but it can be ignored
    useradd --shell /bin/bash -d "$HOME" -u $USER_ID -o -c "" -m "$USER_NAME" > /dev/null 2>&1

    exec /usr/local/bin/gosu "$USER_NAME" bash "$HOME/src/build_in_docker.sh"
fi

