#!/bin/bash
# This script is intended to be run outside the container to download ISO images 
# and mount them to be imported by Cobbler inside the container. 

test -d isos || mkdir -p isos

#####################
#   Fedora Server   #
#####################
URL_FEDORA_SERVER_34="https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/34/Server/x86_64/iso/Fedora-Server-dvd-x86_64-34-1.2.iso"
FILENAME_FEDORA_SERVER_34=$(basename $URL_FEDORA_SERVER_34)
echo "[Download ISO & Mount] Downloading $FILENAME_FEDORA_SERVER_34"
test -d isos/Fedora || mkdir -p isos/Fedora
test -f isos/Fedora/$FILENAME_FEDORA_SERVER_34 || curl $URL_FEDORA_SERVER_34 -o isos/Fedora/$FILENAME_FEDORA_SERVER_34
test -d /mnt/fedora-server-34 || sudo mkdir /mnt/fedora-server-34
echo "[Download ISO & Mount] Mounting $FILENAME_FEDORA_SERVER_34 to /mnt/fedora-server-34"
sudo mount -t iso9660 -o loop,ro isos/Fedora/$FILENAME_FEDORA_SERVER_34 /mnt/fedora-server-34
echo "[Download ISO & Mount] $FILENAME_FEDORA_SERVER_34 downloaded and mounted successfully"

#####################
#   Ubuntu Server   #
#####################
URL_UBUNTU_SERVER_2004="https://releases.ubuntu.com/focal/ubuntu-20.04.6-live-server-amd64.iso"
FILENAME_UBUNTU_SERVER_2004=$(basename $URL_UBUNTU_SERVER_2004)
echo "[Download ISO & Mount] Downloading $FILENAME_UBUNTU_SERVER_2004"
test -f isos/cloud-init/Ubuntu20/$FILENAME_UBUNTU_SERVER_2004 || curl $URL_UBUNTU_SERVER_2004 -o isos/cloud-init/Ubuntu20/$FILENAME_UBUNTU_SERVER_2004
test -d /mnt/ubuntu-server-2004 || sudo mkdir /mnt/ubuntu-server-2004
echo "[Download ISO & Mount] Mounting $FILENAME_UBUNTU_SERVER_2004 to /mnt/ubuntu-server-2004"
sudo mount -t iso9660 -o loop,ro isos/cloud-init/Ubuntu20/$FILENAME_UBUNTU_SERVER_2004 /mnt/ubuntu-server-2004
echo "[Download ISO & Mount] $FILENAME_UBUNTU_SERVER_2004 downloaded and mounted successfully"

URL_UBUNTU_SERVER_2204="https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
FILENAME_UBUNTU_SERVER_2204=$(basename $URL_UBUNTU_SERVER_2204)
echo "[Download ISO & Mount] Downloading $FILENAME_UBUNTU_SERVER_2204"
test -f isos/cloud-init/Ubuntu22/$FILENAME_UBUNTU_SERVER_2204 || curl $URL_UBUNTU_SERVER_2204 -o isos/cloud-init/Ubuntu22/$FILENAME_UBUNTU_SERVER_2204
test -d /mnt/ubuntu-server-2204 || sudo mkdir /mnt/ubuntu-server-2204
echo "[Download ISO & Mount] Mounting $FILENAME_UBUNTU_SERVER_2204 to /mnt/ubuntu-server-2204"
sudo mount -t iso9660 -o loop,ro isos/cloud-init/Ubuntu22/$FILENAME_UBUNTU_SERVER_2204 /mnt/ubuntu-server-2204
echo "[Download ISO & Mount] $FILENAME_UBUNTU_SERVER_2204 downloaded and mounted successfully"

URL_UBUNTU_SERVER_2404="https://releases.ubuntu.com/noble/ubuntu-24.04.4-live-server-amd64.iso"
FILENAME_UBUNTU_SERVER_2404=$(basename $URL_UBUNTU_SERVER_2404)
echo "[Download ISO & Mount] Downloading $FILENAME_UBUNTU_SERVER_2404"
test -f isos/cloud-init/Ubuntu24/$FILENAME_UBUNTU_SERVER_2404 || curl $URL_UBUNTU_SERVER_2404 -o isos/cloud-init/Ubuntu24/$FILENAME_UBUNTU_SERVER_2404
test -d /mnt/ubuntu-server-2404 || sudo mkdir /mnt/ubuntu-server-2404
echo "[Download ISO & Mount] Mounting $FILENAME_UBUNTU_SERVER_2404 to /mnt/ubuntu-server-2404"
sudo mount -t iso9660 -o loop,ro isos/cloud-init/Ubuntu24/$FILENAME_UBUNTU_SERVER_2404 /mnt/ubuntu-server-2404
echo "[Download ISO & Mount] $FILENAME_UBUNTU_SERVER_2404 downloaded and mounted successfully"

###################
#   Rocky Linux   #
###################
URL_ROCKY_9="https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.7-x86_64-dvd.iso"
FILENAME_ROCKY_9=$(basename $URL_ROCKY_9)
echo "[Download ISO & Mount] Downloading $FILENAME_ROCKY_9"
test -d isos/Rocky || mkdir -p isos/Rocky
test -f isos/Rocky/$FILENAME_ROCKY_9 || curl $URL_ROCKY_9 -o isos/Rocky/$FILENAME_ROCKY_9
test -d /mnt/rocky-9 || sudo mkdir /mnt/rocky-9
echo "[Download ISO & Mount] Mounting $FILENAME_ROCKY_9 to /mnt/rocky-9"
sudo mount -t iso9660 -o loop,ro isos/Rocky/$FILENAME_ROCKY_9 /mnt/rocky-9
echo "[Download ISO & Mount] $FILENAME_ROCKY_9 downloaded and mounted successfully"

URL_ROCKY_10="https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.1-x86_64-dvd1.iso"
FILENAME_ROCKY_10=$(basename $URL_ROCKY_10)
echo "[Download ISO & Mount] Downloading $FILENAME_ROCKY_10"
test -d isos/Rocky || mkdir -p isos/Rocky
test -f isos/Rocky/$FILENAME_ROCKY_10 || curl $URL_ROCKY_10 -o isos/Rocky/$FILENAME_ROCKY_10
test -d /mnt/rocky-10 || sudo mkdir /mnt/rocky-10
echo "[Download ISO & Mount] Mounting $FILENAME_ROCKY_10 to /mnt/rocky-10"
sudo mount -t iso9660 -o loop,ro isos/Rocky/$FILENAME_ROCKY_10 /mnt/rocky-10
echo "[Download ISO & Mount] $FILENAME_ROCKY_10 downloaded and mounted successfully"