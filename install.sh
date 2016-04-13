#!/bin/bash

# Install all dotfiles
dotfiles=(.vimrc .Xdefaults .bash_profile .gitconfig .xinitrc)
for dotfile in ${dotfiles[*]}; do
    printf "Installing %s...\n" $dotfile
    ln -s `pwd`/$dotfile ~/$dotfile 2>/dev/null
done

echo "Installing custom oh-my-zsh themes..."
ln -s `pwd`/themes ~/.oh-my-zsh/custom/themes 2>/dev/null

mkdir -p ~/.vim/autoload ~/.vim/bundle ~/.vim/colors

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    echo "Downloading Vundle.vim..."
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

if [ ! -d ~/.vim/bundle/vim-material-theme ]; then
    cd ~/.vim/bundle
    echo "Downloading material-theme for vim..."
    git clone https://github.com/jdkanani/vim-material-theme
    # curl -LSso ~/.vim/colors/material-theme.vim https://raw.githubusercontent.com/jdkanani/vim-material-theme/master/colors/material-theme.vim
fi

git update-index --assume-unchanged .gitconfig
echo "Don't forget to set your git shit"
echo "git config --global user.name \"something\""
echo "git config --global user.email \"something@something.com\""
