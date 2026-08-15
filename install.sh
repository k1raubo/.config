#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cp -r "$SCRIPT_DIR/.config/." ~/.config/
cp "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf

echo "Installed!"
