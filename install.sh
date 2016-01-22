#!/bin/bash

# Install all dotfiles
dotfiles=(.vimrc .Xdefaults .bash_profile .gitconfig)
for dotfile in ${dotfiles[*]}; do
    printf "Installing %s...\n" $dotfile
    ln -s `pwd`/$dotfile ~/$dotfile 2>/dev/null
done

mkdir -p ~/.vim/autoload ~/.vim/bundle

if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
    echo "Installing pathogen for vim..."
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
fi

echo "Don't forget to set your git shit"
echo "git config --global user.name \"something\""
echo "git config --global user.email \"something@something.com\""

