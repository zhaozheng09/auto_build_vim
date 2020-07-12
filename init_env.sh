#!/bin/bash

source ~/env.sh

dw_python="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/python3.8.3/Python-3.8.3.tgz"
dw_vim="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/vim-8.2/vim-8.2.tar.bz2"
dw_rc="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/vimrc"
dw_ycm_config="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/ycm_extra_conf.py"
dw_a="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/a.vim"
pcre="http://mirror.centos.org/centos/7/os/x86_64/Packages/pcre-devel-8.32-17.el7.x86_64.rpm"
automake="https://ftp.gnu.org/gnu/automake/automake-1.16.2.tar.gz"
autoconf="ftp://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz"
m4="http://ftp.gnu.org/gnu/m4/m4-1.4.9.tar.gz"
gcc74="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/gcc-7.4.0.tar.xz"
gmp="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/gmp-6.1.0.tar.bz2"
isl="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/isl-0.16.1.tar.bz2"
mpc="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/mpc-1.0.3.tar.gz"
mpfr="https://s3plus.sankuai.com/v1/mss_f98ae29a284a4de8952b082c29b58dfb/zhaozheng09/custom/mpfr-3.1.4.tar.bz2"
glibc="https://ftp.gnu.org/gnu/glibc/glibc-2.19.tar.bz2"
make="https://ftp.gnu.org/gnu/make/make-4.3.tar.gz"
bison="https://ftp.gnu.org/gnu/bison/bison-3.6.tar.xz"
pcre="ftp://ftp.pcre.org/pub/pcre/pcre-8.42.tar.bz2"
pkg="https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
libtool="http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz"
function check() {
    if [ $3 -ne 0 ]
    then
        echo "------------------------"
        echo "$1 $2 failed ."
        echo "------------------------"
        exit
    fi
}

home=`pwd`
software="$home/software"
local="$home/local"

function init() {
    rm /usr/bin/python
    ln -s /usr/bin/python2.6 /usr/bin/python
    cd
    mkdir software
    mkdir local
}
#------ install python
function install_python() {
    cd && cd software
    rm Python-3.8.3.tgz
    wget $dw_python
    name="python3.8.3"
    check "download" $name $?

    tar xzf Python-3.8.3.tgz
    cd Python-3.8.3
    python_local="$local/$name"
    mkdir $python_local
    echo "-----"
    echo $python_local
    echo "-----"
    ./configure --prefix=$python_local --enable-shared --enable-optimizations
    check "config" $name $?
    make -j 32
    check "make" $name $?
    make install
    check "install" $name $?

    bin="$python_local/bin"
    lib="$python_local/lib64:$python_local/lib"

    export PATH="$bin:$PATH"
    export LD_LIBRARY_PATH="$lib:$LD_LIBRARY_PATH"
    ln -s $bin/python3 $bin/python
}

# -------- install vim
function install_vim() {
    name="ncurses"
    yum install -y ncurses-devel.x86_64
    yum install -y bzip2
    check "download" $name $?

    name="vim-8.2"
    cd && cd software
    rm vim-8.2.tar.bz2
    wget $dw_vim
    check "download" $name $?
    tar xf vim-8.2.tar.bz2
    cd vim82
    vim_local="$local/$name"
    mkdir $vim_local
    echo $vim_local
    ./configure --prefix=$vim_local --enable-python3interp=dynamic
    make -j 32 && make install

    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

    echo "set encoding=utf-8" > $HOME/.vimrc
    echo "set rtp+=~/.vim/bundle/Vundle.vim" >> $HOME/.vimrc
    echo "call vundle#begin()"              >> $HOME/.vimrc
    echo "Plugin 'VundleVim/Vundle.vim'" >> $HOME/.vimrc
    echo "call vundle#end()" >> $HOME/.vimrc

    vim +BundleInstall +qall
}

# -------- install ycm
function install_ycm() {
    git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe
    cd ~/.vim/bundle/YouCompleteMe
    git submodule update --init --recursive

    echo "set encoding=utf-8" > $HOME/.vimrc
    echo "set rtp+=~/.vim/bundle/Vundle.vim" >> $HOME/.vimrc
    echo "call vundle#begin()"              >> $HOME/.vimrc
    echo "Plugin 'VundleVim/Vundle.vim'" >> $HOME/.vimrc
    echo "Plugin 'Valloric/YouCompleteMe'" >> $HOME/.vimrc
    echo "call vundle#end()" >> $HOME/.vimrc

    echo "vim +BundleInstall +qall" | bash

    cd ~/.vim/bundle/YouCompleteMe
    python3 install.py --clang-completer

    cd
    wget $dw_ycm_config
    mv ycm_extra_conf.py .ycm_extra_conf.py

}

#----------- install color
function install_vimrc() {
    cd
    wget $dw_rc
    rm ~/.vimrc
    mv vimrc ~/.vimrc
    vim +BundleInstall +qall
}

#--------- install a.vim
function install_a_vim() {
    name="a.vim"
    cd && mkdir ~/.vim/plugin
    rm $name
    wget $dw_a
    mv a.vim ~/.vim/plugin/
}

function install_pcre() {
    cd && cd software
    rm pcre-8.42.tar.bz2
    wget $pcre
    tar xjf pcre-8.42.tar.bz2
    cd pcre-8.42
    ./configure --prefix=$local/pcre
    make && make install

}

function install_pkg() {
    cd && cd software
    rm pkg-config-0.29.2.tar.gz
    wget $pkg
    tar xf pkg-config-0.29.2.tar.gz
    cd pkg-config-0.29.2
    ./configure --prefix=$local/pkg
    make && make install
}

function install_lzma() {
    cd && cd software
    git clone https://github.com/kobolabs/liblzma.git
    cd liblzma
    sh autogen.sh
    ./configure --prefix=$local/lzma
    make -j 32 && make install
}

function install_ag() {
    install_m4
    install_autoconf
    install_automake
    install_pcre
    install_pkg
    export PKG_CONFIG_PATH=/tmp/workspace/local/pcre/lib/pkgconfig/:$PKG_CONFIG_PATH
    cd && cd software
    install_lzma
    rm -rf the_silver_searcher
    git clone https://github.com/ggreer/the_silver_searcher.git
    cd the_silver_searcher
    sed -e 15a\\"AC_SEARCH_OPTS=\"-I /tmp/workspace/local/pkg/share/aclocal\"" autogen.sh > autogen.sh
    sh autogen.sh
    ./configure --prefix=$local/ag
    make && make install
}

function install_m4() {
    cd && cd software
    rm m4-1.4.9.tar.gz
    wget $m4
    tar xf m4-1.4.9.tar.gz
    cd ~/software/m4-1.4.9
    ./configure --prefix=$local/m4
    make && make install
    export PATH=$local/m4:$PATH
}

function install_autoconf() {
    cd && cd software
    rm autoconf-latest.tar.gz
    wget $autoconf
    tar xf autoconf-latest.tar.gz
    cd autoconf-2.69
    ./configure --prefix=$local/autoconf
    make && make install
    export PATH=$local/autoconf:$PATH
}

function install_automake() {
    cd && cd software
    wget $automake
    tar xf automake-1.16.2.tar.gz
    cd automake-1.16.2
    ./configure --prefix=$local/automake
    make && make install
    export PATH=$local/automake:$PATH
}

function install_gcc74() {
    cd && cd software
    rm gcc-7.4.0.tar.xz
    rm gmp-6.1.0.tar.bz2
    rm isl-0.16.1.tar.bz2
    rm mpc-1.0.3.tar.gz
    rm mpfr-3.1.4.tar.bz2
    rm gcc-7.4.0.tar
    rm gcc-7.4.0

    wget $gcc74
    wget $mpfr
    wget $mpc
    wget $isl
    wget $gmp

    xz -d gcc-7.4.0.tar.xz
    tar xf gcc-7.4.0.tar
    tar xjf gmp-6.1.0.tar.bz2
    tar xjf isl-0.16.1.tar.bz2
    tar xzf mpc-1.0.3.tar.gz
    tar xjf mpfr-3.1.4.tar.bz2
    mv gmp-6.1.0 gcc-7.4.0/gmp
    mv isl-0.16.1 gcc-7.4.0/isl
    mv mpc-1.0.3 gcc-7.4.0/mpc
    mv mpfr-3.1.4 gcc-7.4.0/mpfr

    cd gcc-7.4.0
    mkdir build
    cd build
    ../configure --prefix=$local/gcc74 -disable-multilib
    make -j 48 && make install

}

function install_glibc() {
    cd && cd software
    rm glibc-2.19.tar.bz2
    wget $glibc
    tar xjf glibc-2.19.tar.bz2
    cd glibc-2.19
    mkdir build
    cd build
    ../configure --prefix=$local/glibc
    make -j 48
    make install
}

function install_make() {
    cd && cd software
    rm make-4.3.tar.gz
    wget $make
    tar xzf make-4.3.tar.gz
    cd make-4.3
    ./configure --prefix=$local/make
    make -j 32 && make install

}

function install_bison() {
    cd && cd software
    rm bison-3.6.tar.xz
    wget $bison
    xz -d bison-3.6.tar.xz
    tar xf bison-3.6.tar
    cd bison-3.6
    ./configure --prefix=$local/bison
    make -j 32 && make install
}

function install_libtool() {
    cd && cd software
    #rm libtool-2.4.6.tar.gz
    #wget $libtool
    #tar xf libtool-2.4.6.tar.gz
    cd libtool-2.4.6
    #sh autogen.sh
    #./configure --prefix=$local/libtool
    make && make install
}

if [ "$1" == "init" ]
then
    init
    install_python
    install_vim
    install_a_vim
    install_vimrc
    install_ag
fi
