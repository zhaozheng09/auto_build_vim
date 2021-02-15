#!/bin/bash
source ./init_env.sh
source `echo $env_script`
source `echo $source_script` 
export unexpected_quit=0

trap 'onCtrlC' INT
function onCtrlC () {
    echo 'Ctrl+C is captured'
    export unexpected_quit=1
}

function auto_get_download_name() {
    echo ${1##*/}    
}

function download_wrapper() {
    download_fin=1
    retry=10
    wait_costs_secs=600
    echo 1 > /dev/shm/foo
    filename=$(auto_get_download_name $1)

    function real_download() {
        echo "start download $1"
        wget $1
        ret=$?
        echo "download return val: $ret"
        echo $ret > /dev/shm/foo
    }

    for i in {1..10}
    do
        real_download $1
        if [ $? -eq 0 ]
        then
            return 0
        fi
    done
}

function is_installed() {
    if [ ! -d "$1" ]
    then
        return 1
    fi
    if [ "`ls -A $1`" = "" ]
    then
        return 1
    else
        echo "$1 has been installed ."
        return 0
    fi
}

function check_ret() {
    if [ $3 -ne 0 ]
    then
        echo "------------------------"
        echo "$1 $2 failed, ret:$3"
        echo "------------------------"
        exit
    fi
}

home=$HOME
software="$home/software"
local="$home/local"

function init() {
    #rm /usr/bin/python
    #ln -s /usr/bin/python2.6 /usr/bin/python
    cd
    mkdir software
    mkdir local
    yum install xz
    yum install perl
    yum install perl-Thread-Queue
}

function install_openssl() {
    name="openssl-1.0.2"
    openssl_local="$local/$name"
    is_installed $openssl_local
    if [ $? -eq 0 ]
    then    
        return 0
    fi

    cd && cd software
    echo "================================ rm "
    rm openssl-1.0.2.tar.gz 
    get_source $name
    download_wrapper $source_addr
    check_ret "download" $name $?

    tar xzf openssl-1.0.2.tar.gz 
    cd $name
    mkdir $openssl_local
    ./config --prefix=$openssl_local -fPIC
    check_ret "config" $name $?
    make -j 32 
    make -j 32 
    # test error .
    #check_ret "make" $name $?
    make depend
    check_ret "depend" $name $?
    make install
    check_ret "install" $name $?

    bin="$openssl_local/bin"
    lib="$openssl_local/lib64:$openssl_local/lib"

    export PATH="$bin:$PATH"
    export LD_LIBRARY_PATH="$lib:$LD_LIBRARY_PATH"
}

#------ install python
function install_python() {
    name="Python-3.8.3"
    python_local="$local/$name"
    is_installed $python_local
    if [ $? -eq 0 ]
    then    
        return 0
    fi

    export PKG_CONFIG_PATH=$local/openssl-1.0.2/lib/pkgconfig/:$PKG_CONFIG_PATH
    yum -y install gcc gcc-c++ zlib zlib-devel libffi-devel
    yum -y install gcc kernel-devel kenel-headers make bzip2
    yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel

    cd && cd software
    rm Python-3.8.3.tgz
    get_source $name
    download_wrapper $source_addr
    check_ret "download" $name $?

    tar xzf Python-3.8.3.tgz
    cd Python-3.8.3
    mkdir $python_local
    #./configure --prefix=$python_local --enable-shared --enable-optimizations
    ./configure --prefix=$python_local --enable-shared
    check_ret "config" $name $?
    make -j 32
    check_ret "make" $name $?
    make install
    check_ret "install" $name $?

    bin="$python_local/bin"
    lib="$python_local/lib64:$python_local/lib"

    export PATH="$bin:$PATH"
    export LD_LIBRARY_PATH="$lib:$LD_LIBRARY_PATH"
    ln -s $bin/python3 $bin/python
}

# -------- install vim
function install_vim() {
    name="vim-8.2"
    vim_local="$local/$name"
    is_install $vim_local
    if [ $? -eq 0 ]
    then
        return 0
    fi

    name="ncurses"
    yum install -y ncurses-devel.x86_64
    yum install -y bzip2
    check_ret "download" $name $?

    name="vim-8.2"
    cd && cd software
    rm vim-8.2.tar.bz2
    get_source $name
    download_wrapper $source_addr
    check_ret "download" $name $?
    tar xf vim-8.2.tar.bz2
    cd vim82
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
    name='ycm_config'
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
    get_source $name
    download_wrapper $source_addr
    mv ycm_extra_conf.py .ycm_extra_conf.py

}

#----------- install color
function install_vimrc() {
    name='vimrc'
    cd
    get_source $name
    download_wrapper $source_addr
    rm ~/.vimrc
    mv vimrc ~/.vimrc
    vim +BundleInstall +qall
}

#--------- install a.vim
function install_a_vim() {
    name='a.vim'
    cd && mkdir ~/.vim/plugin
    rm $name
    get_source $name
    download_wrapper $source_addr
    mv a.vim ~/.vim/plugin/
}

function install_pcre() {
    name='pcre-8.42'
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return 
    fi
    cd && cd software
    rm pcre-8.42.tar.bz2
    get_source $name
    download_wrapper $source_addr
    tar xjf pcre-8.42.tar.bz2
    cd pcre-8.42
    ./configure --prefix=$local/$name
    make && make install

}

function install_pkg() {
    name="pkg-config-0.29.2"
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return 
    fi
    cd && cd software
    rm pkg-config-0.29.2.tar.gz
    get_source $name
    download_wrapper $source_addr
    tar xf pkg-config-0.29.2.tar.gz
    cd pkg-config-0.29.2
    ./configure --prefix=$local/$name --with-internal-glib=$local/glibc
    make && make install
}

function install_lzma() {
    name="lzma"
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi

    cd && cd software
    git clone https://github.com/kobolabs/liblzma.git
    cd liblzma
    sh autogen.sh
    ./configure --prefix=$local/$name
    make -j 32 && make install
    yum install -y xz-devel
}

function install_ag() {
    name="ag"
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi

    install_m4
    install_autoconf
    install_automake
    install_pcre
    install_lzma
    cd && cd software
    export PKG_CONFIG_PATH=$local/$pcre/lib/pkgconfig/:$PKG_CONFIG_PATH
    export PKG_CONFIG_PATH=$local/$lzma/lib/pkgconfig/:$PKG_CONFIG_PATH
    rm -rf the_silver_searcher
    git clone https://github.com/ggreer/the_silver_searcher.git
    cd the_silver_searcher
    #sed -e 15a\\"AC_SEARCH_OPTS=\"-I $local/pkg/share/aclocal\"" autogen.sh > test.txt
    #cp -rf test.txt autogen.sh
    sh autogen.sh
    cp /usr/share/aclocal/pkg.m4 m4/ 
    autoreconf -i -f
    aclocal -I m4
    autoconf
    name="ag"
    ./configure --prefix=$local/$name
    make && make install
}

function install_m4() {
    name='m4-1.4.9'
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi
    cd && cd software
    rm m4-1.4.9.tar.gz
    get_source $name
    download_wrapper $source_addr
    check_ret "download" "m4" $? 
    tar xf m4-1.4.9.tar.gz
    cd ~/software/m4-1.4.9
    ./configure --prefix=$local/$name
    make && make install
    export PATH=$local/m4:$PATH
}

function install_autoconf() {
    name='autoconf-2.69'
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi
    cd && cd software
    rm autoconf-2.69.tar.gz
    get_source $name
    download_wrapper $source_addr
    check_ret "download" "autoconf" $? 
    tar xf autoconf-2.69.tar.gz
    cd autoconf-2.69
    ./configure --prefix=$local/$name
    make && make install
    export PATH=$local/autoconf:$PATH
}

function install_automake() {
    name='automake-1.16.2'
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi
    cd && cd software
    rm automake-1.16.2.tar.gz
    get_source $name
    download_wrapper $source_addr
    check_ret "download" "automke" $? 
    tar xf automake-1.16.2.tar.gz
    cd automake-1.16.2
    ./configure --prefix=$local/$name
    sed -i 's/$(update_mans) automake-$(APIVERSION)/$(update_mans) automake-$(APIVERSION) --no-discard-stderr/g' Makefile
    make && make install
    export PATH=$local/automake:$PATH
}

function install_gcc74() {
    name="gcc74"
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi
    cd && cd software
    rm gcc-7.4.0.tar.xz
    rm gcc-7.4.0.tar
    rm gcc-7.4.0
    get_source $name
    download_wrapper $source_addr
    xz -d gcc-7.4.0.tar.xz
    tar xf gcc-7.4.0.tar

    rm gmp-6.1.0.tar.bz2
    get_source 'gmp-6.1.0' 
    download_wrapper $source_addr
    tar xjf gmp-6.1.0.tar.bz2
    mv gmp-6.1.0 gcc-7.4.0/gmp

    rm isl-0.16.1.tar.bz2
    get_source 'isl-0.16.1'
    download_wrapper $source_addr
    tar xjf isl-0.16.1.tar.bz2
    mv isl-0.16.1 gcc-7.4.0/isl

    rm mpc-1.0.3.tar.gz
    get_source 'mpc-1.0.3'
    download_wrapper $source_addr
    tar xzf mpc-1.0.3.tar.gz
    mv mpc-1.0.3 gcc-7.4.0/mpc

    rm mpfr-3.1.4.tar.bz2
    get_source 'mpfr-3.1.4'
    download_wrapper $source_addr
    tar xjf mpfr-3.1.4.tar.bz2
    mv mpfr-3.1.4 gcc-7.4.0/mpfr

    cd gcc-7.4.0
    mkdir build
    cd build
    ../configure --prefix=$local/$name -disable-multilib
    make -j 48 && make install

}

function install_glibc() {
    name='glibc-2.19'
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi

    cd && cd software
    rm glibc-2.19.tar.bz2
    get_source $name
    download_wrapper $source_addr
    tar xjf glibc-2.19.tar.bz2
    cd glibc-2.19
    mkdir build
    cd build
    ../configure --prefix=$local/$name
    make -j 48
    make install
}

function install_make() {
    name='make-4.3'
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi
    cd && cd software
    rm make-4.3.tar.gz
    get_source $name
    download_wrapper $source_addr
    tar xzf make-4.3.tar.gz
    cd make-4.3
    ./configure --prefix=$local/$name
    make -j 32 && make install

}

function install_bison() {
    name='bison-3.6'
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi
    cd && cd software
    rm bison-3.6.tar.xz
    get_source $name
    download_wrapper $source_addr
    xz -d bison-3.6.tar.xz
    tar xf bison-3.6.tar
    cd bison-3.6
    ./configure --prefix=$local/$name
    make -j 32 && make install
}

function install_libtool() {
    name='libtool-2.4.6'
    is_installed "$local/$name"
    if [ $? -eq 0 ]
    then
        return
    fi
    cd && cd software
    rm libtool-2.4.6.tar.gz
    get_source $name
    download_wrapper $source_addr
    tar xf libtool-2.4.6.tar.gz
    cd libtool-2.4.6
    sh autogen.sh
    ./configure --prefix=$local/$name
    make && make install
}

if [ "$1" == "init" ]
then
    init
    install_openssl
    install_python
    install_vim
    install_a_vim
    install_vimrc
    install_ag
fi
#install_automake
install_ag

