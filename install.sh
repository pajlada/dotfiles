#!/bin/bash

# Usage: make_home_symlink path_to_file name_of_file_in_home_to_symlink_to
make_home_symlink() {
    printf "Installing %s...\n" $1

    # Remove pre-existing symlink
    unlink ~/$2 2>/dev/null

    # Make new symlink
    ln -s `pwd`/$1 ~/$2 2>/dev/null
}

# Possible devices: desktop, laptop
DEVICE="${1:-desktop}"

echo "Install symlinks as device $DEVICE"

# Install all shared dotfiles
dotfiles=(.vimrc .bash_profile .gitconfig .gvimrc .gvimrc4k .Xmodmap .gdbinit)

for dotfile in ${dotfiles[*]}; do
    make_home_symlink $dotfile $dotfile
done

# Device-specific symlinks
make_home_symlink .xinitrc-${DEVICE} .xinitrc
make_home_symlink .Xdefaults-${DEVICE} .Xdefaults

echo "Installing custom oh-my-zsh themes..."
cp themes/* ~/.oh-my-zsh/custom/themes/ 2>/dev/null

mkdir -p ~/.vim/autoload ~/.vim/bundle ~/.vim/colors

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    echo "Installing Vundle.vim..."
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

if [ ! -f ~/.vim/colors/pixelmuerto.vim ]; then
    echo "Installing vim pixelmuerto color theme"
    git clone https://github.com/pixelmuerto/vim-pixelmuerto.git
    cp vim-pixelmuerto/colors/* ~/.vim/colors/
fi

make_home_symlink i3-${DEVICE} .config/i3
make_home_symlink i3status-${DEVICE} .config/i3status

git update-index --assume-unchanged .gitconfig
echo "Don't forget to set your personal git configs"
echo "git config --global user.name \"something\""
echo "git config --global user.email \"something@something.com\""
