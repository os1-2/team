#!/bin/bash

# 수정날짜: 2020/10/05

# 사용법
# ./build.sh (option)
# 0) ./buils.sh env    -> 최초 tos build 환경 설정
# 1) ./build.sh tos    -> only tos_build 빌드
# 2) ./build.sh toc    -> only toc_build 빌드
# 3) ./build.sh full   -> pkg, tos, toc 빌드
# 4) ./build.sh clean  -> clean 빌드
# 5) ./buils.sh remove -> binary 제거
# 6) ./buils.sh togate -> togate 설치(version 수정필요)
# 7) ./buils.sh gtest  -> gtest 설치


# TOS_PATH 수정 필수!!!!!!
TOS_PATH="/root/master"

TMP_ARCH=`uname -m`

if [ "${TMP_ARCH}" == i686 ]; then
    ARCH="i686"
elif [ "${TMP_ARCH}" == x86_64 ]; then
    ARCH="x86_64"
else
    echo "unsupported architecture"
    exit 1
fi

function install_pkg(){
  cd ${TOS_PATH}/pkg/
  ./install_linux_pkg.sh -a
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail(pkg install)"
    echo -e "\033[0m"
    exit 1
  fi
}

function tos_build_env_setting(){
  #ctags
  apt-get -y install exuberant-ctags

  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

  install_pkg

  update-alternatives --set cc /usr/bin/clang
  update-alternatives --set c++ /usr/bin/clang++
  ln -s /usr/bin/make /usr/bin/gmake
}

function tos_debug_build(){
  cd ${TOS_PATH}/build/
  ./init_debug.sh
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail(tos_build ./init_debug.sh)"
    echo -e "\033[0m"
    exit 1
  fi

  cd ~/tos_build/binary_debug/
  make install -j8

  cd ~/tos_build/binary_debug/src/core
  make install -j8
  cd ~/tos_build/binary_debug/src/lib/tgk
  make install -j8
  cd ~/tos_build/binary_debug/src/lib
  make install -j8
  cd ~/tos_build/binary_debug/src/lib/t2d
  make install -j8
  cd ~/tos_build/binary_debug/src/lib/cop_common/
  make install -j8
  cd ~/tos_build/binary_debug/src/gk_repo
  make install -j8
  cd ~/tos_build/binary_debug/src/res_pak
  make install -j8
  cd ~/tos_build/binary_debug/
  make install -j8

  # 이제 걸리면, 진짜 문제 생겨서 안되는 거임. 
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail(tos_build make install), one more try tos_build..."
    echo -e "\033[0m"
    exit 1
  fi
}

function toc_debug_build(){
  cd ${TOS_PATH}/src/toc/build/
  ./init_debug.sh
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail(toc_build ./init_debug.sh)"
    echo -e "\033[0m"
    exit 1
  fi

  cd ~/toc_build/binary_debug/
  make install -j8
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail(toc_build make install)"
    echo -e "\033[0m"
    exit 1
  fi
}

function tos_release_build(){
  cd ${TOS_PATH}/build/
  ./init_release.sh
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail(tos_build ./init_release.sh)"
    echo -e "\033[0m"
    exit 1
  fi

  cd ~/tos_build/binary_release/
  make install -j8
  cd ~/tos_build/binary_release/src/core
  make install -j8
  cd ~/tos_build/binary_release/src/lib/tgk
  make install -j8
  cd ~/tos_build/binary_release/src/lib
  make install -j8
  cd ~/tos_build/binary_release/src/lib/t2d
  make install -j8
  cd ~/tos_build/binary_release/src/lib/cop_common
  make install -j8
  cd ~/tos_build/binary_release/src/gk_repo
  make install -j8
  cd ~/tos_build/binary_release/src/res_pak
  make install -j8
  cd ~/tos_build/binary_release/
  make install -j8

  # 이제 걸리면, 진짜 문제 생겨서 안되는 거임. 
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail(tos_build make install), one more try tos_build..."
    echo -e "\033[0m"
    exit 1
  fi
}

function toc_release_build(){
  cd ${TOS_PATH}/src/toc/build/
  ./init_release.sh
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail(toc_build ./init_release.sh)"
    echo -e "\033[0m"
    exit 1
  fi

  cd ~/toc_build/binary_release/
  make install -j8
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail(toc_build make install)"
    echo -e "\033[0m"
    exit 1
  fi
}

# full build function
function full_debug_build_function(){
  cd ${TOS_PATH}
  cp config.cmake.eg config.cmake

  # pkg install
  install_pkg

  # webview install
  install_webview

  # tos build
  tos_debug_build

  if [ "${ARCH}" == "i686" ]; then
    # toc build 
    toc_debug_build
  fi
}

function full_release_build_function(){
  cd ${TOS_PATH}
  cp config.cmake.eg config.cmake

  # pkg install
  install_pkg

  # webview install
  install_webview

  # tos build
  tos_release_build


  if [ "${ARCH}" == "i686" ]; then
    # toc build 
    toc_release_build
  fi
}

# remove output binary debug
function remove_output_binary_debug(){
    cd ~/tos_build/binary_debug/
    make clean-all
    
    systemctl stop cwmd
    pkill cwm

    cd ${TOS_PATH}
    if [ $? -ne 0 ]; then
      echo -e "\033[31m"
      echo "Fail cd ${TOS_PATH}"
      echo -e "\033[0m"
      exit 1
    fi
    rm -rf *
    git reset --hard HEAD
    git submodule update
    rm -rf /system /tos /rsmdata /windata ~/toc_build ~/tos_build
}

# remove output binary release
function remove_output_binary_release(){
    cd ~/tos_build/binary_release/
    make clean-all
    
    systemctl stop cwmd
    pkill cwm

    cd ${TOS_PATH}
    if [ $? -ne 0 ]; then
      echo -e "\033[31m"
      echo "Fail cd ${TOS_PATH}"
      echo -e "\033[0m"
      exit 1
    fi
    rm -rf *
    git reset --hard HEAD
    git submodule update
    rm -rf /system /tos /rsmdata /zone /windata ~/toc_build ~/tos_build
}

function make_zone_debug(){
  #zone 설치
  cd ~/tos_build/binary_debug/src/boot/zone/bin
  make zone-refresh
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail to make zone"
    echo -e "\033[0m"
    exit 1
  fi
}

function make_zone_release(){
  #zone 설치
  cd ~/tos_build/binary_release/src/boot/zone/bin
  make zone-refresh
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail to make zone"
    echo -e "\033[0m"
    exit 1
  fi
}

function install_gtest(){
  echo "install gtest, wait plz.."
  git clone https://github.com/google/googletest.git
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail to git clone"
    echo -e "\033[0m"
    exit 1
  fi
  cd googletest/googletest
  git reset --hard 509f7fe8
  cmake .
  make install -j8
  cp libgtest.a libgtest_main.a /usr/lib/
  cp -r ~/googletest/googletest/include/gtest /usr/include/
}

function install_togate(){
  ADDRESS="togate@192.168.12.50"
  PASSWORD="tmaxos123!"
  VERSION="latest"
  if [ "${ARCH}" == "i686" ]; then
    sshpass -p${PASSWORD} scp -o StrictHostKeyChecking=no -P 12369 ${ADDRESS}:~/package/i386/ToGate.tai .
  else
    sshpass -p${PASSWORD} scp -o StrictHostKeyChecking=no -P 12369 ${ADDRESS}:~/package/amd64/${VERSION}/ToGate.tai .
  fi
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail to download ToGate.tai"
    echo -e "\033[0m"
    exit 1
  fi

  #Togate 설치
  /system/bin/mkapp -d ./ToGate.tai -o /system/app/
  rm ToGate.tai
}

function install_webview(){
  ADDRESS="togate@192.168.12.50"
  PASSWORD="tmaxos123!"
  VERSION="latest"
  if [ "${ARCH}" == "i686" ]; then
    sshpass -p${PASSWORD} scp -o StrictHostKeyChecking=no -P 12369 ${ADDRESS}:~/package/i386/webview.tai .
  else
    sshpass -p${PASSWORD} scp -o StrictHostKeyChecking=no -P 12369 ${ADDRESS}:~/package/amd64/${VERSION}/webview.tai .
  fi
  if [ $? -ne 0 ]; then
    echo -e "\033[31m"
    echo "Fail to download ToGate.tai"
    echo -e "\033[0m"
    exit 1
  fi

  #webview install
  tar -xvf webview.tai -C /
}

if [ "$1" == "full" ]; then
  echo -n "Do you want full build? (debug:d / release:r)(d/r)"
  read input
  if [ $input == "D" ] || [ $input == "d" ]; then
    full_debug_build_function
  fi
  if [ $input == "R" ] || [ $input == "r" ]; then
    full_release_build_function
  fi
fi

# tos build
if [ "$1" == "tos" ]; then
  echo -n "Do you want tos_build (debug:d / release:r)? (d/r)"
  read input
  if [ $input == "D" ] || [ $input == "d" ]; then
    tos_debug_build
  fi
  if [ $input == "R" ] || [ $input == "r" ]; then
    tos_release_build
  fi
fi


# toc build
if [ "$1" == "toc" ]; then
  echo -n "Do you want toc_build (debug:d / release:r)? (d/r)"
  read input
  if [ $input == "D" ] || [ $input == "d" ]; then
      toc_debug_build
  fi
  if [ $input == "R" ] || [ $input == "r" ]; then
      toc_release_build
  fi
fi

# remove binary
if [ "$1" == "remove" ]; then
  echo -n "Do you want to remove all binary? (debug:d / release:r)"
  read input
  if [ $input == "D" ] || [ $input == "d" ]; then
    remove_output_binary_debug
  fi
  if [ $input == "R" ] || [ $input == "r" ]; then
    remove_output_binary_release
  fi
fi

# clean debug build
if [ "$1" == "clean" ]; then
  echo -n "Do you want clean_build? (debug:d / release:r)"
  read input
  if [ $input == "D" ] || [ $input == "d" ]; then
    remove_output_binary_debug
    full_debug_build_function
  fi

  if [ $input == "R" ] || [ $input == "r" ]; then
    remove_output_binary_release
    full_release_build_function
  fi

  #Togate install
  install_togate

  echo "clean build finish!!"
fi

# install togate
if [ "$1" == "togate" ]; then
  echo -n "Do you want to install togate? (Y/N)"
  read input
  if [ $input == "Y" ] || [ $input == "y" ]; then
    install_togate
  fi
fi

if [ "$1" == "webview" ]; then
  echo -n "Do you want to install webview? (Y/N)"
  read input
  if [ $input == "Y" ] || [ $input == "y" ]; then
    install_webview
  fi
fi


if [ "$1" == "gtest" ]; then
  echo -n "Do you want to install gtest? (Y/N)"
  read input
  if [ $input == "Y" ] || [ $input == "y" ]; then
    install_gtest
  fi
fi

if [ "$1" == "zone" ]; then
  echo -n "Do you want to make zone? (debug:d / release:r)"
  read input
  if [ $input == "D" ] || [ $input == "d" ]; then
    make_zone_debug
  fi
  if [ $input == "R" ] || [ $input == "r" ]; then
    make_zone_release
  fi
fi

if [ "$1" == "env" ]; then
  echo "start env setting."
  tos_build_env_setting
  echo "finish env  setting."
fi

# build option 없을 경우
if [ "$1" == "" ]; then
  echo -e "You have to put build option. (check build.sh line:3)"
fi
