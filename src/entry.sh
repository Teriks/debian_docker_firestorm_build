#!/bin/bash

# /home/fs_build exists as a mounted volume, useradd warns that it exists but it can be ignored
useradd --shell /bin/bash -d /home/fs_build -u $LOCAL_USER_ID -o -c "" -m "$LOCAL_USER" > /dev/null 2>&1

export HOME=/home/fs_build
exec /usr/local/bin/gosu "$LOCAL_USER" bash ~/src/build_in_docker.sh

