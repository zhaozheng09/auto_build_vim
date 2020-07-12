#!/bin/bash

#export HOME=/root

sw="$HOME/software"
lc="$HOME/local"

python="python3.8.3"
vim="vim-8.2"

export PATH="$lc/$python/bin:$PATH"
export LD_LIBRARY_PATH="$lc/$python/lib64:$lc/$python/lib:$LD_LIBRARY_PATH"

export PATH="$lc/$vim/bin:$PATH"
export LD_LIBRARY_PATH="$lc/$vim/lib64:$lc/$vim/lib:$LD_LIBRARY_PATH"

export PATH="$lc/m4/bin/:$PATH"
export PATH="$lc/automake/bin:$PATH"
export PATH="$lc/autoconf/bin:$PATH"

#export PATH="$lc/gcc74/bin:$PATH:$lc/gcc74/libexec"
#export LD_LIBRARY_PATH="$lc/gcc74/lib64/:$lc/gcc74/lib/:$LD_LIBRARY_PATH"

export PATH="$lc/make/bin:$PATH"
echo $PATH

export PATH="$lc/bison/bin:$PATH"
export LD_LIBRARY_PATH="$lc/bison/lib:$LD_LIBRARY_PATH"

#export PATH="$lc/glibc/bin:$lc/glibc/libexec:$PATH"
#export PATH="$lc/glibc/bin:$PATH"
#export LD_LIBRARY_PATH="$lc/glibc/lib64:$lc/glibc/lib:$LD_LIBRARY_PATH"
