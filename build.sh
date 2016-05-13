#!/bin/bash -ex

BUILD_DATE=`date +%Y%m%d-%H%M%S`

#CREATE BACKUP DIRECTORY
if [ ! -e 'backups' ]; then
    mkdir backups
fi

#BACKUP LOCAL BUILD KEY
if [ -e 'key-build' ]; then
    cp -n key-build ./backups/
    cp key-build ./backups/key-build.${BUILD_DATE}-$$
fi
if [ -e 'key-build.pub' ]; then
    cp -n key-build.pub ./backups/
    cp key-build.pub ./backups/key-build.pub.${BUILD_DATE}-$$
fi

#INIT KERNEL CONFIG
if [ ! -e '.config' ]; then
    cp openwrt-yun-minimum.config .config
else
    cp .config ./backups/config.${BUILD_DATE}-$$
fi

#BACKUP DL FOLDER
if [ -e 'dl' ]; then
    mv dl dl.orig
fi

#CLEAN
make clean
make dirclean
make distclean

#RESTORE DL FOLDER
if [ -e 'dl.orig' ]; then
    mv dl.orig dl
fi

#RESTORE LOCAL BUILD KEY
if [ -e 'backups/key-build' ]; then
    cp ./backups/key-build .
fi
if [ -e 'backups/key-build.pub' ]; then
    cp ./backups/key-build.pub .
fi

#FEEDS
./scripts/feeds uninstall -a
rm -rf feeds
./scripts/feeds update -a
./scripts/feeds install -a

#UNINSTALL BROKEN PACKAGES
#./scripts/feeds uninstall aria2 freecwmp libfreecwmp libmicroxml crtmpserver dansguardian

#DELETE PACKAGES
#rm -rf ./package/feeds/packages/node
#rm -rf ./package/feeds/packages/node-arduino-firmata
#rm -rf ./package/feeds/packages/node-cylon
#rm -rf ./package/feeds/packages/node-hid
#rm -rf ./package/feeds/packages/node-serialport

#LINK CUSTOM PACKAGES
#ln -s ../../../feeds/arduino/node ./package/feeds/arduino/
#ln -s ../../../feeds/arduino/node-arduino-firmata ./package/feeds/arduino/
#ln -s ../../../feeds/arduino/node-cylon ./package/feeds/arduino/
#ln -s ../../../feeds/arduino/node-hid ./package/feeds/arduino/
#ln -s ../../../feeds/arduino/node-serialport ./package/feeds/arduino/

# PATCH PACKAGES
sed -i -e s/^START=98/START=48/ ./feeds/packages/utils/rng-tools/files/rngd.init
sed -i -e s/^RNGD_AMOUNT=4000/RNGD_AMOUNT=4096/ ./feeds/packages/utils/rng-tools/files/rngd.init

# PATCH KERNEL CONFIG
if [ -z "`git status|fgrep ar71xx/config-4.1`" ]; then
    patch -p1 < ./patches/000-MIPS24Kc+PCI+FPU_EMU.patch
fi
if [ -z "`git status|fgrep ar71xx/Makefile`" ]; then
    patch -p1 < ./patches/000-TARGET_CPU_TYPE.patch
fi

#COPY CONFIG FILE
mv .config ./backups/feeds-config.${BUILD_DATE}-$$
if [ -z "`fgrep 'LEDE Configuration' Config.in`" ]; then
    cp openwrt-yun-minimum.config .config
else
    cp lede-yun-minimum.config .config
fi

make oldconfig
make
