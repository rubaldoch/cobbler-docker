#!/bin/bash
mkdir isos

URL_FEDORA_34="https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/34/Server/x86_64/iso/Fedora-Server-dvd-x86_64-34-1.2.iso"
FILENAME_FEDORA_34=$(basename $URL_FEDORA_34)
echo "Downloading $FILENAME_FEDORA_34"
test -f isos/$FILENAME_FEDORA_34 || curl $URL_FEDORA_34 -o isos/$FILENAME_FEDORA_34
test -d /mnt/fedora-34 || sudo mkdir /mnt/fedora-34
sudo mount -t iso9660 -o loop,ro isos/$FILENAME_FEDORA_34 /mnt/fedora-34