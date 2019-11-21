#!/bin/sh

set -eu

# Make backup of hosts file
sudo cp /etc/hosts /etc/hosts.bkp

# Generate host.conf file specific to your server
echo "127.0.1.1 $(hostname)" > hosts.d/host.conf

# Ensure hosts.d folder exists
sudo rsync -avz --no-perms --no-owner --no-group hosts.d /etc/

# Ensure dotfiles binary folder exists
sudo mkdir -p /opt/pajlada-dotfiles

# Install script into dotfiles binary folder
sudo cp combine-hosts.sh /opt/pajlada-dotfiles/

# Install systemd unit and timer file
sudo cp pajlada-combine-hosts.* /etc/systemd/system/
sudo systemctl daemon-reload

# Enable timer
sudo systemctl enable --now pajlada-combine-hosts.timer
