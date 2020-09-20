#!/bin/bash

#export HOME=/root

export TERM=xterm-256color

sw="$HOME/software"
lc="$HOME/local"

python='python3.8.3'
vim='vim-8.2'

python='Python-3.8.3'
vim='vim-8.2'
vimrc='vimrc'
ycm_config='ycm_config'
a_vim='a.vim'
gcc='gcc74'
gmp='gmp-6.1.0'
isl='isl-0.16.1'
mpc='mpc-1.0.3'
mpfr='mpfr-3.1.4'
automake='automake-1.16.2'
autoconf='autoconf-2.69'
m4='m4-1.4.9'
pcre='pcre-8.42'
ag='ag'
glibc='glibc-2.19'
lzma='lzma'
export pcre="$pcre"
export lzma="$lzma" 

export PATH="$lc/$python/bin:$PATH"
export LD_LIBRARY_PATH="$lc/$python/lib64:$lc/$python/lib:$LD_LIBRARY_PATH"

export PATH="$lc/$vim/bin:$PATH"
export LD_LIBRARY_PATH="$lc/$vim/lib64:$lc/$vim/lib:$LD_LIBRARY_PATH"

export PATH="$lc/$m4/bin/:$PATH"
export PATH="$lc/$automake/bin:$PATH"
export PATH="$lc/$autoconf/bin:$PATH"

export PATH="$lc/$gcc/bin:$PATH:$lc/$gcc/libexec"
export LD_LIBRARY_PATH="$lc/$gcc/lib64/:$lc/$gcc/lib/:$LD_LIBRARY_PATH"

export PATH="$lc/$make/bin:$PATH"

export PATH="$lc/$bison/bin:$PATH"
export LD_LIBRARY_PATH="$lc/$bison/lib:$LD_LIBRARY_PATH"

export LD_LIBRARY_PATH="$lc/$pcre/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$lc/$lzma/lib:$LD_LIBRARY_PATH"
export PATH="$lc/$pcre/bin:$PATH"
export PATH="$lc/$ag/bin:$PATH"

#export PATH="$lc/glibc/bin:$lc/glibc/libexec:$PATH"
#export PATH="$lc/glibc/bin:$PATH"
#export LD_LIBRARY_PATH="$lc/glibc/lib64:$lc/glibc/lib:$LD_LIBRARY_PATH"
