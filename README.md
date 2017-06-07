# About

Scripts to build Firestorm Viewer in an x64 bit Ubuntu 16.04 docker container.

The produced binary should be compatible with most debian distros when you
install the correct dependencies listed on Firestorm's website.

The build produced uses FMOD Ex (Sound) which is supplied locally, but not KDU (Openjpeg Instead).


# Configuring The Viewer


See viewer.conf for configurable options such as the viewer channel, viewer repo, and repo tag.


# Building


1. Install docker for your platform.

2. Clone this repository and CD into the repo directory.

3. (Optionally) hg clone the Firestorm repo into the folder `firestorm-source` and make modifications.  If you don't do this step, it will be downloaded from the repo in `viewer.conf` at the given tag (default is tip).

4. CD into the repository directory and run `./build.sh`.

6. Wait a (really) long time for it to build.  The first run of `build.sh` builds a docker image and compiles inside it, following builds use the already built image from your local docker registry.

5. `firestorm-source/build-linux-x86_64/newview` will contain the build artifacts.


# On Windows

The build works with git-bash (MINGW64) and Cygwin bash on Windows with Docker for Windows installed.

A caveat is that the build artifacts will be owned by 'Administrators', because Windows cannot handle
permissions correctly for files in a volume mounted from the host machine.

Everything in the mounted volume is owned by 'root' from the containers point of view.


# LL Autobuild Package Cache

The download/install cache directory for the Linden autobuild tool is mapped to the directory `install.cache` in repo folder.

When `build.sh` is run for the first time, this directory will be created and autobuild will download archived dependencies into it for the build system to consume.

As long as this directory persist, the dependencies will not need to be re-downloaded in the container when you run another build.







