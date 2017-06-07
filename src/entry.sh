#!/bin/bash

export HOME=/home/fs_build

if [ "$ON_WINDOWS" = true ]
then
    # Windows does not care about volume permissions
    exec $HOME/src/build_in_docker.sh
else
    USER_ID=${LOCAL_USER_ID:-9001}
    USER_NAME=${LOCAL_USER:-build_user}

    # /home/fs_build exists as a mounted volume, useradd warns that it exists but it can be ignored
    useradd --shell /bin/bash -d $HOME -u $USER_ID -o -c "" -m "$USER_NAME" > /dev/null 2>&1

    exec /usr/local/bin/gosu "$USER_NAME" bash $HOME/src/build_in_docker.sh
fi

