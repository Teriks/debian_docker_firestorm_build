# About

Scripts to build Firestorm Viewer in an x64 bit Ubuntu 16.04 docker container.

The produced binary should be compatible with most debian distros when you
install the correct dependencies listed on Firestorm's website.

The build produced uses fmodstudio (Sound) which is supplied locally, but not KDU (Openjpeg Instead).


# Configuring The Viewer/Build


See `config/build.conf` for configurable options such as the viewer channel, viewer repo, and repo tag.

`config/build.conf` expects bash syntax.


# Building On Linux

1. Have at least 8 gigs of RAM, or set `USE_SWAPFILE=true` and `SWAPFILE_SIZE` in `config/build.conf`

2. Install docker for your platform. (https://www.docker.com/)

3. Clone this repository and CD into the repo directory.

4. (Optionally) hg clone the Firestorm repo into the folder `firestorm-source` and make modifications.  If you don't do this step, it will be downloaded from the repo in `config/build.conf` at the given tag (default is tip).

5. (Optionally) hg clone the Firestorm fs-build-variables repo into the folder `build-variables` and make modifications.  If you don't do this step, it will be downloaded from the repo in `config/build.conf` at the given tag (default is tip).

6. CD into this repository directory and run `./build.sh`.  (My repo, not the one in `firestorm-source` if you manually cloned it!).

7. Wait a (really) long time for it to build.  The first run of `build.sh` builds a docker image and compiles inside it, following builds use the already built image from your local docker registry.

8. `firestorm-source/build-linux-x86_64/newview` will contain the build artifacts.


# Building On Windows


The build works with Git-Bash (MINGW64) and Cygwin bash on Windows with Docker for Windows installed.

However, the Viewer source and LL autobuild dependencies are cloned/downloaded into a named docker volume instead of mounted folders in this repo's directory.

This is because Windows has problems building the source tree from a mounted host folder, due to case insensitive file system behavior in mounted Windows directories.

When the build is complete, a **tar.xz** archive containing the built and packaged viewer is copied into a folder named `artifacts` in this repo directory (on the host).

The named volume allows successive runs of the build to re-use the previously downloaded (or partially built) repository, and any dependencies downloaded by LL autobuild.

A caveat of this is that you can only interact with the `firestorm-source` and `install.cache` folder on Windows by using the interactive build shell mentioned below.


**Note:**  

Your going to have to provision around 7 to 8 gigs of memory for the Windows docker daemon, or gcc will encounter internal compiler errors.

Set `USE_SWAPFILE=true` and `SWAPFILE_SIZE` in `config/build.conf` if you can't do this.


# Interactive Build Shell

`./build.sh -i` will drop you into an interactive shell running inside the docker container.

The working directory will be the build directory.

If you are building on Windows, the `install.cache`, `firestorm-source`, and `build-variables` directories
will actually be located inside of a named docker volume instead of the repo directory on the host.

On Linux, the entire directory you cloned this repo into will be mapped into the container.

**Note:**

Git-Bash works best on Windows for using the interactive shell because it comes with `winpty` by default,
which allows for a user friendly terminal instead of a STDIN prompt.


# Build With Pakefile

If you have python 3.5+ installed, you can also use the pakefile to start the build and interact with the container.

You need to install:  https://github.com/Teriks/pake

On Linux:  `sudo pip3 install python-pake --upgrade`

On Windows:  `pip install python-pake --upgrade`


You can start the build by CD'ing into this repo's directory and running `pake`.

You can also start the interactive build shell by running `pake shell`.

For future reference, use `pake -ti` to list all documented pake tasks.


The advantage of using pake is that the interactive build shell will offer a
standard prompt in pretty much every shell, including CMD.exe and Powershell on Windows.

On cygwin you can get a TTY prompt if `winpty` is available.  Git-Bash has `winpty` by default.









