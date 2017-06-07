FROM ubuntu:16.04

RUN apt-get update

RUN apt-get --yes install --install-recommends \
bison bzip2 cmake curl flex g++-4.8-multilib gcc-4.8-multilib \
m4 mercurial python2.7 python2.7-dev python-pip libc6-dev libgl1-mesa-dev \
libglu1-mesa-dev libstdc++6 libx11-dev libxinerama-dev libxml2-dev libxrender-dev

RUN apt-get --yes install gdb libpng16-16 libpixman-1-0 libcairo2 libxcomposite1 libxcursor1 libxrandr2

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 48 \
--slave /usr/bin/g++ g++ /usr/bin/g++-4.8 \
--slave /usr/bin/gcov gcov /usr/bin/gcov-4.8


RUN pip install --upgrade pip && pip install --upgrade setuptools
RUN pip install hg+https://bitbucket.org/NickyD/autobuild-1.0#egg=autobuild


RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu
    
    
WORKDIR /home/fs_build

ENTRYPOINT ["/bin/bash"]

