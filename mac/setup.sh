#!/bin/bash

function install_homebrew {
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew update
    brew upgrade
    brew doctor
}

function install_requirements {
    brew install automake autoconf libtool gcc
    brew install pkgconfig
    brew install icu4c
    brew install leptonica jpeg jbig2 jbig2dec libtiff libpng
}

function install_gs {
    brew install ghostscript
}

function install_tesseract {
    cd /tmp/
    git clone https://github.com/tesseract-ocr/tesseract/
    cd tesseract
    ./autogen.sh
    ./configure CC=/usr/local/bin/gcc-8 CXX=/usr/local/bin/g++-8 CPPFLAGS=-I/usr/local/opt/icu4c/include LDFLAGS=-L/usr/local/opt/icu4c/lib
    make -j
    sudo make install
    cd $OLDPWD
}

install_homebrew
install_requirements
install_gs
install_tesseract