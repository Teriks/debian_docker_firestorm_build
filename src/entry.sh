#!/bin/bash

function do_interactive_shell_message()
{
    if [ "$INTERACTIVE_MESSAGE" = true ]
    then
        echo "=========================================="
        echo "Dropping into interactive container shell."
        echo "Current directory is: \"$PWD\"".
        echo "Leave with 'exit'."
        echo "=========================================="
        echo ""
    fi
}

source config/build.conf

USE_SWAPFILE=${USE_SWAPFILE,,}

export HOME=/home/build
export BUILD_DIR=$HOME

if [ $USE_SWAPFILE = true ] ; then
    if [ ! -f ~/$SWAPFILE_NAME ] ;
    then
        echo "Creating swapfile of size: $SWAPFILE_SIZE ..."
        fallocate -l $SWAPFILE_SIZE ~/$SWAPFILE_NAME
        chmod 600 ~/$SWAPFILE_NAME
        mkswap ~/$SWAPFILE_NAME
        echo "Finished creating swapfile."
    fi
    swapon ~/$SWAPFILE_NAME && echo "Swapfile activated."
fi

read -r -d '' RC_FILE <<-EOF
SWAPFILE_ACTIVE=$USE_SWAPFILE
function clean_swap {
	if [ $USE_SWAPFILE = true ] && [ $SWAPFILE_ACTIVE=true ] ; then
		sudo swapoff ~/$SWAPFILE_NAME && set SWAPFILE_ACTIVE=false && echo "Swapfile deactivated." 
	fi
}
trap clean_swap 0
EOF


if [ "$ON_WINDOWS" = true ]
then
    export USER=root

    # Resident to the container, build system reads cached dependencies from here
    mkdir /var/tmp/root
    
    # Make in the named volume if it does not exist
    mkdir -p "$HOME/install.cache"
    
    # Make the install.cache local to the volume by linking it, so it can be messed with from the interactive shell on windows and be persistant.
    ln -s "$HOME/install.cache" /var/tmp/root/install.cache
    
    do_interactive_shell_message
    
    # Windows does not care about volume permissions, just enter the shell as root
    exec /bin/bash --rcfile <(echo "$RC_FILE") "$@"
else
    USER_ID=${LOCAL_USER_ID:-9001}
    USER_NAME=${LOCAL_USER:-build_user}

    export USER=$USER_NAME
    
    # /home/fs_build exists as a mounted volume, useradd warns that it exists but it can be ignored
    useradd --shell /bin/bash -d "$HOME" -u $USER_ID -o -c "" -m "$USER_NAME" > /dev/null 2>&1

    groupadd docker_shared
    usermod -aG docker_shared "$USER_NAME"

    echo '%docker_shared ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

    # make the rcfile outside the working directory
    # in some place thats not persisted. Make it readable
    # by the newly created user.

    TMPFILE=$(mktemp /tmp/rcfile.XXXXXXXXXX)
    echo "$RC_FILE" > $TMPFILE
    chown "$USER_NAME:docker_shared" $TMPFILE
    
    do_interactive_shell_message

    exec /usr/local/bin/gosu "$USER_NAME" /bin/bash --rcfile $TMPFILE "$@"
fi







