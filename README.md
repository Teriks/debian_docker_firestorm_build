Scripts to build Firestorm Viewer in an x64 bit Ubuntu 16.04 docker container.

The produced binary should be compatible with most debian distros when you
install the correct dependencies listed on Firestorm's website.

The build produced uses FMOD Ex (Sound) which is supplied locally, but not KDU (Openjpeg Instead).


# Configuring The Viewer


See viewer.conf for configurable options such as the viewer channel, viewer repo, and repo tag.


# Building


1. Install docker for your (Linux) platform.

2. Clone this repository and CD into the repo directory.

3. (Optionally) hg clone the Firestorm repo into the folder `firestorm-source` and make modifications.  If you don't do this step, it will be downloaded from the repo in viewer.conf at the given tag (default is tip).

4. CD into the repository directory and run `./build.sh`.

6. Wait a (really) long time for it to build.  The first run of build.sh builds a docker image and compiles inside it, runs that follow use the already built image from your local docker registry.

5. `firestorm-source/build-linux-x86_64/newview` will contain the build artifacts. 






