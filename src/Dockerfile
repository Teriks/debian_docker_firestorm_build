FROM ubuntu:16.04

ENV GOSU_VERSION 1.10

RUN apt-get update

RUN set -ex; \
	apt-get install -y --no-install-recommends ca-certificates wget; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true;


RUN apt-get --yes install sudo software-properties-common

RUN add-apt-repository "deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu xenial main" && \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1E9377A2BA9EF27F && \
 apt-get update

RUN apt-get --yes install --install-recommends --allow-unauthenticated \
bison bzip2 cmake curl doxygen flex g++-6 gdb m4 mercurial moreutils pkg-config \
python python-dev python-pip

RUN apt-get --yes install --install-recommends libalut-dev libapr1-dev libaprutil1-dev libatk1.0-dev libboost-all-dev libcairo2-dev \
libcollada-dom2.4-dp-dev libcurl4-openssl-dev libdbus-glib-1-dev libfreetype6-dev libgl1-mesa-dev \
libglu1-mesa-dev libgtk2.0-dev libjpeg-dev libjsoncpp-dev libnghttp2-dev libogg-dev libopenal-dev \
libpangox-1.0-dev libpng-dev libsdl1.2-dev libssl-dev libstdc++6 liburiparser-dev libvorbis-dev libx11-dev \
libxinerama-dev libxml2-dev libxmlrpc-epi-dev libxrender-dev zlib1g-dev

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 6 \ 
--slave /usr/bin/g++ g++ /usr/bin/g++-6 \
--slave /usr/bin/gcov gcov /usr/bin/gcov-6

RUN update-alternatives --config gcc


RUN python -m pip install --upgrade pip
RUN python -m pip install --upgrade setuptools
RUN pip install hg+http://bitbucket.org/lindenlab/autobuild-1.1#egg=autobuild
    
    
WORKDIR /home/build

ENTRYPOINT ["/bin/bash"]

