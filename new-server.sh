#!/bin/sh

# stop motd from showing up
touch ~/.hushlogin

# install standard software
sudo apt install zsh curl

# set zsh as the default shell
sudo chsh -s /usr/bin/zsh "$USER"
