FROM ubuntu:16.04
RUN apt update && apt --yes install --install-recommends \
bison bzip2 cmake curl flex g++-4.8-multilib gcc-4.8-multilib \
m4 mercurial python2.7 python2.7-dev python-pip libc6-dev libgl1-mesa-dev \
libglu1-mesa-dev libstdc++6 libx11-dev libxinerama-dev libxml2-dev libxrender-dev \
&& \
apt --yes install gdb libpng16-16 libpixman-1-0 libcairo2 libxcomposite1 libxcursor1 libxrandr2 \
&& \
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 48 \
--slave /usr/bin/g++ g++ /usr/bin/g++-4.8 \
--slave /usr/bin/gcov gcov /usr/bin/gcov-4.8 \
&& pip install --upgrade pip && pip install --upgrade setuptools && \
pip install hg+https://bitbucket.org/NickyD/autobuild-1.0#egg=autobuild
