#!/bin/bash
# This script is intended to be run outside the container to download ISO images 
# and mount them to be imported by Cobbler inside the container. 

test -d isos || mkdir -p isos

URL_FEDORA_SERVER_34="https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/34/Server/x86_64/iso/Fedora-Server-dvd-x86_64-34-1.2.iso"
FILENAME_FEDORA_SERVER_34=$(basename $URL_FEDORA_SERVER_34)
echo "[Download ISO & Mount] Downloading $FILENAME_FEDORA_SERVER_34"
test -d isos/cloud-init/Fedora || mkdir -p isos/cloud-init/Fedora
test -f isos/cloud-init/Fedora/$FILENAME_FEDORA_SERVER_34 || curl $URL_FEDORA_SERVER_34 -o isos/cloud-init/Fedora/$FILENAME_FEDORA_SERVER_34
test -d /mnt/fedora-server-34 || sudo mkdir /mnt/fedora-server-34
echo "[Download ISO & Mount] Mounting $FILENAME_FEDORA_SERVER_34 to /mnt/fedora-server-34"
sudo mount -t iso9660 -o loop,ro isos/cloud-init/Fedora/$FILENAME_FEDORA_SERVER_34 /mnt/fedora-server-34
echo "[Download ISO & Mount] $FILENAME_FEDORA_SERVER_34 downloaded and mounted successfully"

URL_UBUNTU_SERVER_2004="https://releases.ubuntu.com/focal/ubuntu-20.04.6-live-server-amd64.iso"
FILENAME_UBUNTU_SERVER_2004=$(basename $URL_UBUNTU_SERVER_2004)
echo "[Download ISO & Mount] Downloading $FILENAME_UBUNTU_SERVER_2004"
test -f isos/cloud-init/Ubuntu20/$FILENAME_UBUNTU_SERVER_2004 || curl $URL_UBUNTU_SERVER_2004 -o isos/cloud-init/Ubuntu20/$FILENAME_UBUNTU_SERVER_2004
test -d /mnt/ubuntu-server-2004 || sudo mkdir /mnt/ubuntu-server-2004
echo "[Download ISO & Mount] Mounting $FILENAME_UBUNTU_SERVER_2004 to /mnt/ubuntu-server-2004"
sudo mount -t iso9660 -o loop,ro isos/cloud-init/Ubuntu20/$FILENAME_UBUNTU_SERVER_2004 /mnt/ubuntu-server-2004
echo "[Download ISO & Mount] $FILENAME_UBUNTU_SERVER_2004 downloaded and mounted successfully"
