#
# References:
#  https://hub.docker.com/r/yhnw/openwrt-sdk/dockerfile
#  https://hub.docker.com/r/fasheng/openwrt-buildsdk/dockerfile
#

FROM ubuntu:19.10

MAINTAINER Satadru Pramanik <satadru@umich.edu>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y apt-utils && apt-get -y upgrade && \
apt-get install -y sudo python python3 file curl libssl-dev \
       build-essential libncurses5-dev libncursesw5-dev g++ gawk git subversion \
       libssl-dev gettext time zlib1g-dev swig unzip wget \
       libelf-dev ecj fastjar java-propose-classpath && \
apt-get -y autoremove && apt-get clean && \
useradd -c "OpenWrt Builder" -m -d /home/openwrt -s /bin/bash openwrt && \
echo 'openwrt ALL=NOPASSWD: ALL' > /etc/sudoers.d/openwrt

USER openwrt
ENV HOME /home/openwrt
WORKDIR /home/openwrt

RUN git clone https://github.com/openwrt/openwrt.git && \
git clone --depth=1 --branch master --single-branch https://github.com/satmandu/openwrt-yun-build-extra.git && \
ln -s /home/openwrt/openwrt-yun-build-extra/* /home/openwrt/openwrt/

#
# For the first time build:
#   'cd openwrt; ./build.sh'
#
# From the next time build:
#   'cd openwrt; ./rebuild.sh
#

CMD ["/bin/bash"]
