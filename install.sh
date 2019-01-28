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

# Install all dotfiles
dotfiles=(.vimrc .Xdefaults .gitconfig .xinitrc .gvimrc .gvimrc4k .Xmodmap .gdbinit .zshrc)
for dotfile in ${dotfiles[*]}; do
    if [ -f ~/$dotfile ] && [ ! -L ~/$dotfile ]; then
        echo -n "You already have a regular file at ~/$dotfile. Do you want to overwrite it? (y/n) "
        read response
        if [ "$response" == "y" ] || [ $"response" == "Y" ]; then
            rm ~/$dotfile
        else
            continue
        fi
    fi

    if [ ! -L ~/$dotfile ]; then
        printf "Installing %s...\n" $dotfile
        ln -s `pwd`/$dotfile ~/$dotfile 2>/dev/null
        make_home_symlink $dotfile $dotfile
    fi
done

# Device-specific symlinks
make_home_symlink .xinitrc-${DEVICE} .xinitrc
make_home_symlink .Xdefaults-${DEVICE} .Xdefaults

echo "Installing custom oh-my-zsh themes..."
# Create oh-my-zsh custom themes folder if it doesn't exist already
mkdir -p ~/.oh-my-zsh/custom/themes
ln -s `pwd`/themes/pajlada.zsh-theme ~/.oh-my-zsh/custom/themes 2>/dev/null

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

echo "To make your .gitconfig up-to-date again, you might need to type: git update-index --no-assume-unchanged .gitconfig"
echo "Put your git 'credentials' in ~/.gitcredentials in the following format:"
echo "[user]"
echo "    name = Your Name"
echo "    email = your@email.com"
echo "Or set it with these commands"
echo "Don't forget to set your personal git configs"
echo "git config --file ~/.gitcredentials user.name \"Your Name\""
echo "git config --file ~/.gitcredentials user.email \"your@email.com\""
