#!/usr/bin/env bash
set -euo pipefail

TOOL4D=/opt/tool4d/tool4d
TOOL4D_URL_LINUX='https://resources-download.4d.com/release/20%20Rx/latest/latest/linux/tool4d.deb'

if [[ -x "$TOOL4D" ]]; then
  echo "tool4d already installed at $TOOL4D"
  exit 0
fi

sudo apt-get update
sudo apt-get install -y curl libc++1 uuid-runtime libfreeimage3 xdg-user-dirs

curl -L -o /tmp/libtinfo5.deb http://archive.ubuntu.com/ubuntu/pool/main/n/ncurses/libtinfo5_6.1-1ubuntu1_amd64.deb
curl -L -o /tmp/libncurses5.deb http://archive.ubuntu.com/ubuntu/pool/main/n/ncurses/libncurses5_6.1-1ubuntu1_amd64.deb
sudo dpkg -i /tmp/libtinfo5.deb /tmp/libncurses5.deb

curl -L -o /tmp/tool4d.deb "$TOOL4D_URL_LINUX"
sudo dpkg --force-depends -i /tmp/tool4d.deb

test -x "$TOOL4D"
echo "tool4d installed at $TOOL4D"
