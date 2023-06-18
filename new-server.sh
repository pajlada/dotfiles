#!/bin/sh

# stop motd from showing up
touch ~/.hushlogin

# install standard software
sudo apt install zsh curl

# set zsh as the default shell
sudo chsh -s /usr/bin/zsh "$USER"

# Create pajlada user

if ! getent passwd pajlada >/dev/null; then
    if [ "$USER" = "root" ]; then
        echo "you are root xd, creating pajlada user"
        echo "Creating pajlada user"
        useradd \
            --shell /usr/bin/zsh \
            --create-home \
            --groups sudo \
            pajlada
        sudo -u pajlada ssh-import-id-gh pajlada
    fi
fi
