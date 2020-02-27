#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#source $DIR/zxenv.sh

cd $DIR
BRANCH=zeus

if cd poky; then 
    git pull; 
else 
    git clone --depth=1 git://git.yoctoproject.org/poky  -b $BRANCH
    cd poky
fi

source oe-init-build-env

# # Install toaster dependencies
pip3 install -r $HOME/shared/poky/bitbake/toaster-requirements.txt
source toaster start webport=0.0.0.0:8000
zsh
