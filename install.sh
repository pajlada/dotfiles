#!/bin/sh

# Usage: make_home_symlink path_to_file name_of_file_in_home_to_symlink_to
make_home_symlink() {
    THIS_DOTFILE_PATH=$1
    HOME_DOTFILE_PATH=$2
    echo "Installing $THIS_DOTFILE_PATH into $HOME_DOTFILE_PATH..."

    if [ -L "$HOME_DOTFILE_PATH" ]; then
        echo "Skipping, because $HOME_DOTFILE_PATH is a symlink"
        return
    fi

    if [ -f "$HOME_DOTFILE_PATH" ] && [ ! -L "$HOME_DOTFILE_PATH" ]; then
        printf "You already have a regular file at %s. Do you want to remove it? (y/n) " "$HOME_DOTFILE_PATH"
        read -r response
        if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
            rm "$HOME/$dotfile"
        else
            return
        fi
    fi

    ln -s "$THIS_DOTFILE_PATH" "$HOME_DOTFILE_PATH" 2>/dev/null
}

# Possible devices: desktop, laptop
DEVICE="${1:-desktop}"

echo "Install symlinks as device $DEVICE"

# Install all dotfiles
dotfiles=".vimrc .Xdefaults .gitconfig .xinitrc .gvimrc .gvimrc4k .Xmodmap .gdbinit .zshrc .tmux.conf"
for dotfile in $dotfiles; do
    make_home_symlink "$(pwd)/$dotfile" "$HOME/$dotfile"
done

# Device-specific symlinks
make_home_symlink ".xinitrc-${DEVICE}" .xinitrc
make_home_symlink ".Xdefaults-${DEVICE}" .Xdefaults

# install oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    echo "Installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
    echo "oh-my-zsh is already installed"
fi

echo "Installing custom oh-my-zsh themes..."
# Create oh-my-zsh custom themes folder if it doesn't exist already
mkdir -p ~/.oh-my-zsh/custom/themes
if [ -f ~/.oh-my-zsh/custom/themes/pajlada.zsh-theme ] && [ ! -L ~/.oh-my-zsh/custom/themes/pajlada.zsh-theme ]; then
    echo "Removing old oh-my-zsh custom 'pajlada' theme"
    rm ~/.oh-my-zsh/custom/themes/pajlada.zsh-theme
fi
ln -s "$PWD/themes/pajlada.zsh-theme" ~/.oh-my-zsh/custom/themes >/dev/null

mkdir -p ~/.vim/autoload ~/.vim/bundle ~/.vim/colors

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    echo "Installing Vundle.vim..."
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

if [ ! -d vim-pixelmuerto-fork ]; then
    echo "Cloning pajlada's fork of pixelmuerto's VIM theme"
    git clone https://github.com/pajlada/vim-pixelmuerto.git vim-pixelmuerto-fork
fi

cp vim-pixelmuerto-fork/colors/pixelmuerto.vim ~/.vim/colors/

make_home_symlink "i3-$DEVICE" .config/i3
make_home_symlink "i3status-$DEVICE" .config/i3status

echo "To make your .gitconfig up-to-date again, you might need to type: git update-index --no-assume-unchanged .gitconfig"
echo "Put your git 'credentials' in ~/.gitcredentials in the following format:"
echo "[user]"
echo "    name = Your Name"
echo "    email = your@email.com"
echo "Or set it with these commands"
echo "Don't forget to set your personal git configs"
echo "git config --file ~/.gitcredentials user.name \"Your Name\""
echo "git config --file ~/.gitcredentials user.email \"your@email.com\""
