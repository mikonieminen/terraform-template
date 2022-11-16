#!/usr/bin/env sh

sudo DEBIAN_FRONTEND=noninteractive apt-get \
    -o Dpkg::Options::=--force-confold \
    -o Dpkg::Options::=--force-confdef \
    -y --allow-downgrades --allow-remove-essential --allow-change-held-packages auto-remove

# Remove authorized keys added by Packer
rm ~/.ssh/authorized_keys

sudo journalctl --flush --vacuum-files=0
