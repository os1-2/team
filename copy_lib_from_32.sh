#!/bin/bash

# 수정날짜: 2020/10/05

CYAN='\e[1;36m'
END='\e[0m'

VERSION="5.0.2" # 버전에 맞게 수정

TARGET_DISK="/dev/sda2"
TARGET="/root/ssd" #32bit tos
TOS_PATH="/root/master"
WORK_DIR="`pwd`"

mkdir -p ${TARGET}

mount ${TARGET_DISK} ${TARGET}

mkdir -p /tos_compatibility

# /system/lib/i386-linux-gnu 압축 및 /tos/windows 압축  on 32bit tos
tar czvf lib-i386-${VERSION}.tar.gz -C ${TARGET}/system/lib i386-linux-gnu
tar czvf windows-${VERSION}.tar.gz -C ${TARGET}/tos windows

cp lib-i386-${VERSION}.tar.gz /tos_compatibility
cp windows-${VERSION}.tar.gz /tos_compatibility

# /system/lib/i386-linux-gnu 압축 해제
cd /tos_compatibility
tar xzvf lib-i386-${VERSION}.tar.gz -C /system/lib/

# /tos/windows 압축 해제
tar xzvf windows-${VERSION}.tar.gz -C /system/boot/root/tos/
tar xzvf windows-${VERSION}.tar.gz -C /tos/

# liblxc.so 설정
mkdir -p /system/boot/root/usr/lib/i386-linux-gnu
cd /system/boot/root/usr/lib/i386-linux-gnu
cp ${TARGET}/usr/lib/i386-linux-gnu/liblxc.so.1.4.0 . 
ln -s liblxc.so.1.4.0 liblxc.so.1
ln -s liblxc.so.1 liblxc.so

# shell_execute 설정
cd /system/bin
rm uks
cp ${TARGET}/system/bin/shell_execute .
cp ${TARGET}/system/bin/uks .
systemctl restart uksd

cp ${TARGET}/system/bin/jcm .
systemctl restart jcmd

cp ${TARGET}/system/bin/mwm .
cp ${TARGET}/system/bin/add_print .
cp ${TARGET}/system/bin/init_user_reg.

cp ${TARGET}/system/bin/toc-wrapper . 
cp ${TARGET}/system/bin/toc-mainloader .
cp ${TARGET}/system/bin/toc-preloader .


mkdir -p /system/toc
cd /system/toc
cp -r ${TARGET}/system/toc/* .

mkdir -p /system/boot/msed_data/rsmdata
cd /system/boot/msed_data/rsmdata
cp ${TARGET}/system/boot/msed_data/rsmdata/* .

#64bit pkg
cd ${TOS_PATH}/pkg/
./install_linux_pkg.sh -u

umount ${TARGET}
rm -rf ${TARGET}

rm -rf ${WORK_DIR}/lib-i386-${VERSION}.tar.gz
rm -rf ${WORK_DIR}/windows-${VERSION}.tar.gz

