#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p ~/.config ~/Pictures ~/.oh-my-zsh ~/environments

cp -r "$SCRIPT_DIR/.config/." ~/.config/
cp "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf
cp "$SCRIPT_DIR/.zshrc" ~/.zshrc
cp -r "$SCRIPT_DIR/Pictures/." ~/Pictures/
cp -r "$SCRIPT_DIR/.oh-my-zsh/." ~/.oh-my-zsh/
cp -r "$SCRIPT_DIR/environments/." ~/environments/

echo "Installed!"
