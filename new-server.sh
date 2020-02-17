#!/bin/sh

# stop motd from showing up
touch ~/.hushlogin

# install zsh
sudo apt install zsh

# set zsh as the default shell
sudo chsh -s /usr/bin/zsh "$USER"
