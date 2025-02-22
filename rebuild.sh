#!/bin/bash -ex

git pull
./scripts/feeds update -a
./scripts/feeds install -a

#DELETE OPENWRT NODE PACKAGES
rm  -f ./package/feeds/packages/node
rm  -f ./package/feeds/packages/node-*

#INSTALL CUSTOM NODE PACKAGES
#./scripts/feeds install -a -p node

#DELETE OPENWRT MRAA PACKAGES
rm -f ./package/feeds/packages/libmraa
rm -f ./package/feeds/packages/libupm

#INSTALL CUSTOM MRAA PACKAGES
#./scripts/feeds install -a -p inteliot

#DELETE OPENWRT PAHO-MQTT PACKAGE
rm -f ./package/feeds/packages/python-paho-mqtt

#INSTALL CUSTOM PACKAGES
#./scripts/feeds install -a -p custom

cp openwrt-yun-19.07.diffconfig .config

make defconfig
make
