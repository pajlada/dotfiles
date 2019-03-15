#!/bin/bash

# stop motd from showing up
touch ~/.hushlogin

# install zsh
sudo apt install zsh

# set zsh as the default shell
sudo chsh -s /usr/bin/zsh  $USER

# install oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi
