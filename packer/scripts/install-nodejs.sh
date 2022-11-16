#!/bin/sh
set -eu

sh /tmp/install-nvm.sh

export NVM_DIR="$HOME/.nvm"
#shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

nvm install --lts=gallium

npm install -g yarn
