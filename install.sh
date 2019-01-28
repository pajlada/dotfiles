#!/bin/bash

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
    fi
done

echo "Installing custom oh-my-zsh themes..."
cp themes/* ~/.oh-my-zsh/custom/themes/ 2>/dev/null

mkdir -p ~/.vim/autoload ~/.vim/bundle ~/.vim/colors

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    echo "Downloading Vundle.vim..."
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

if [ ! -d ~/.vim/colors/pixelmuerto.vim ]; then
    git clone https://github.com/pixelmuerto/vim-pixelmuerto.git
    cp vim-pixelmuerto/colors/* ~/.vim/colors/
fi

if [ ! -d ~/.vim/bundle/vim-material-theme ]; then
    cd ~/.vim/bundle
    echo "Downloading material-theme for vim..."
    git clone https://github.com/jdkanani/vim-material-theme
    # curl -LSso ~/.vim/colors/material-theme.vim https://raw.githubusercontent.com/jdkanani/vim-material-theme/master/colors/material-theme.vim
fi

ln -s `pwd`/awesome ~/.config/awesome 2>/dev/null

rm -rf ~/.config/i3
ln -s `pwd`/i3 ~/.config/i3 2>/dev/null
rm -rf ~/.config/i3status
ln -s `pwd`/i3status ~/.config/i3status 2>/dev/null

git update-index --assume-unchanged .gitconfig
echo "Don't forget to set your git shit"
echo "git config --global user.name \"something\""
echo "git config --global user.email \"something@something.com\""
