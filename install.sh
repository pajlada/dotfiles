#!/bin/sh

set -e

# Usage: make_home_symlink path_to_file name_of_file_in_home_to_symlink_to
make_home_symlink() {
    if [ -z "$1" ]; then
        >&2 echo "make_home_symlink: missing first argument: path to file"
        exit 1
    fi

    THIS_DOTFILE_PATH="$PWD/$1"
    if [ -z "$2" ]; then
        HOME_DOTFILE_PATH="$HOME/$1"
    else
        HOME_DOTFILE_PATH="$HOME/$2"
    fi

    printf "Installing %s into %s" "$1" "$HOME_DOTFILE_PATH"

    if [ -L "$HOME_DOTFILE_PATH" ]; then
        echo " skipping, target is already a symlink"
        return
    fi

    if [ -f "$HOME_DOTFILE_PATH" ] && [ ! -L "$HOME_DOTFILE_PATH" ]; then
        printf " You already have a regular file at %s. Do you want to remove it? (y/n) " "$HOME_DOTFILE_PATH"
        read -r response
        if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
            rm "$HOME_DOTFILE_PATH"
        else
            return
        fi
    fi

    ln -s "$THIS_DOTFILE_PATH" "$HOME_DOTFILE_PATH" 2>/dev/null
    echo " done!"
}

# Possible devices: desktop, laptop
DEVICE="${1:-desktop}"

echo "Install symlinks as device $DEVICE"

mkdir -p "$HOME/.config"

# zsh
## Create zsh config dir
mkdir -p "$HOME/.cache/zsh"

## Symlink our zsh dir into ~/.config
make_home_symlink ".config/zsh"

## Symlink our .zprofile file into ~/
make_home_symlink ".zprofile"

## Symlink our .zprofile file into ~/.bash_profile
make_home_symlink ".bash_profile" ".zprofile"

make_home_symlink ".config/bc"

make_home_symlink ".config/nvim"

make_home_symlink ".config/parcellite"

# Bulk install various dotfiles
dotfiles=".gitconfig .Xmodmap .gdbinit .tmux.conf"
for dotfile in $dotfiles; do
    make_home_symlink "$dotfile"
done

# Install aliases used by our shell
make_home_symlink ".config/aliasrc"

make_home_symlink ".xserverrc"

# Device-specific symlinks
make_home_symlink ".Xdefaults-${DEVICE}" ".Xdefaults"

make_home_symlink ".xinitrc" ".xinitrc"

mkdir -p "$HOME/.config/xinit/xinitrc.d"


plug_path="${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim
if [ ! -f "$plug_path" ]; then
    echo "Installing vim-plug..."
    curl -fLo "$plug_path" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if [ ! -d .cloned-st ]; then
    git clone https://github.com/pajlada/st .cloned-st
fi

(
cd .cloned-st && \
    git pull && \
    rm -f config.h && \
    make && \
    sudo make install
)

make_home_symlink "sway" .config/sway
make_home_symlink "i3-$DEVICE" .config/i3
make_home_symlink "i3status-$DEVICE" .config/i3status

if [ ! -f ~/.gitcredentials ]; then
    echo "To make your .gitconfig up-to-date again, you might need to type: git update-index --no-assume-unchanged .gitconfig"
    echo "Put your git 'credentials' in ~/.gitcredentials in the following format:"
    echo "[user]"
    echo "    name = Your Name"
    echo "    email = your@email.com"
    echo "Or set it with these commands"
    echo "Don't forget to set your personal git configs"
    echo "git config --file ~/.gitcredentials user.name \"Your Name\""
    echo "git config --file ~/.gitcredentials user.email \"your@email.com\""
fi

_distro="$(grep '^ID=' /etc/*-release | cut -d= -f2)"

if [ "$_distro" = "arch" ]; then
    if [ ! -d .cloned-yay ]; then
        echo "Installing yay"
        (
        git clone https://aur.archlinux.org/yay.git .cloned-yay && \
            cd .cloned-yay && \
            makepkg -si --noconfirm
        )
    fi

    # Make sure reflector timer is enabled
    sudo systemctl enable --now reflector.timer
fi

if [ ! -f "$HOME/.config/zsh/.zsh_local" ]; then
    echo "You do not have a $HOME/.config/zsh/.zsh_local on your system"
    echo "You can create one and fill it in with things to, for example, automatically load your private key when your shell starts"
fi

echo "Installing all pacman packages:"
echo "jq -r '.packages[]' archinstall/user_configuration.json | xargs sudo pacman -S --noconfirm --needed"

if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Shell not detected as zsh, changing it"
    chsh -s /usr/bin/zsh
fi

if [ ! -f /etc/X11/xorg.conf.d/50-pajlada-set-logitech-mouse-speed.conf ]; then
    echo "Installing Logitech mouse speed xorg config"
    sudo cp xorg.conf.d/50-pajlada-set-logitech-mouse-speed.conf /etc/X11/xorg.conf.d
fi

if [ ! -f /etc/X11/xorg.conf.d/50-pajlada-disable-mouse-accel.conf ]; then
    echo "Installing mouse acceleration disabler"
    sudo cp xorg.conf.d/50-pajlada-disable-mouse-accel.conf /etc/X11/xorg.conf.d
fi

# Update locale
sudo localectl set-x11-keymap us pc105 altgr-intl nodeadkeys
