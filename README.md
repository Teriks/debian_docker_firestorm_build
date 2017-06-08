# About

Scripts to build Firestorm Viewer in an x64 bit Ubuntu 16.04 docker container.

The produced binary should be compatible with most debian distros when you
install the correct dependencies listed on Firestorm's website.

The build produced uses FMOD Ex (Sound) which is supplied locally, but not KDU (Openjpeg Instead).


# Configuring The Viewer


See viewer.conf for configurable options such as the viewer channel, viewer repo, and repo tag.


# Building On Linux

1. Have at least 8 gigs of RAM.

2. Install docker for your platform.

3. Clone this repository and CD into the repo directory.

4. (Optionally) hg clone the Firestorm repo into the folder `firestorm-source` and make modifications.  If you don't do this step, it will be downloaded from the repo in `viewer.conf` at the given tag (default is tip).

5. CD into the repository directory and run `./build.sh`.

6. Wait a (really) long time for it to build.  The first run of `build.sh` builds a docker image and compiles inside it, following builds use the already built image from your local docker registry.

7. `firestorm-source/build-linux-x86_64/newview` will contain the build artifacts.


# Building On Windows


The build works with git-bash (MINGW64) and Cygwin bash on Windows with Docker for Windows installed.

However, the Viewer source and LL autobuild dependencies are cloned/downloaded into a named docker volume instead of mounted folders in this repo's directory.

This is because Windows has problems building the source tree from a mounted host folder, due to case insensitive file system behavior in mounted Windows directories.

When the build is complete, the folder `firestorm-source/build-linux-x86_64/newview` from the source tree is copied into a folder named `artifacts` in this repo directory (on the host).

The named volume allows successive runs of the build to re-use the previously downloaded (or partially built) repository, and any dependencies downloaded by LL autobuild.

A caveat of this is that you can only interact with the `firestorm-source` and `install.cache` folder on Windows by using the interactive build shell mentioned below.


**Note:**  Your going to have to provision around 7 to 8 gigs of memory for the Windows docker daemon, or gcc will encounter internal compiler errors.


# Interactive Build Shell

`./build.sh -i` will drop you into an interactive shell running inside the docker container.

The working directory will be the build directory.

If you are building on Windows, the `install.cache` and `firestorm-source` directories in the build directory
will actually be located inside of a named docker volume instead of in this repo's directory.


On Linux, the entire directory you cloned this repo into will be mapped into the container.







