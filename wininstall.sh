#!/bin/bash

# Install all dotfiles
dotfiles=(.vimrc .gitconfig)
for dotfile in ${dotfiles[*]}; do
    printf "Installing %s...\n" $dotfile
    cp `pwd`/$dotfile ~/$dotfile 2>/dev/null
done

cp `pwd`/.gvimrcWindows ~/.gvimrc

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    echo "Downloading Vundle.vim..."
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

if [[ ! -f ~/vimfiles/colors/pixelmuerto.vim ]]; then
    echo "Installing PixelMuerto color scheme..."
    git clone https://github.com/pixelmuerto/vim-pixelmuerto
    mkdir -p ~/vimfiles/colors
    cp vim-pixelmuerto/colors/pixelmuerto.vim ~/vimfiles/colors/
    rm -rf vim-pixelmuerto
fi

git update-index --assume-unchanged .gitconfig
echo "Don't forget to set your git shit"
echo "git config --global user.name \"something\""
echo "git config --global user.email \"something@something.com\""
