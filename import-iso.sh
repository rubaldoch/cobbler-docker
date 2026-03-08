#!/bin/bash
# This script is intended to be run inside the container to import the mounted 
# ISO images into Cobbler and create corresponding profiles.

if [ ! -f "/usr/local/bin/cobbler" ]; then
  echo "This script should only be run in container, execute:"
  echo "\$ docker exec -it cobbler-3.7 /bin/bash -c \"\$(<import-iso.sh)\""
  exit 1
fi

#####################
#   Fedora Server   #
#####################

PROFILE_NAME="Fedora-Server-34"
echo "[Import ISO] Importing "$PROFILE_NAME""
cobbler import --name="$PROFILE_NAME"  --path /mnt/fedora-server-34 --arch=x86_64
if [[ $? -eq 0 ]]; then
    for PROFILE in $(cobbler profile list | grep "$PROFILE_NAME");do
        echo "[Import ISO] Creating generic ks file for $PROFILE"
        cat /var/lib/cobbler/templates/sample.ks | grep -v "\--useshadow" | grep -v ^install | sed 's,selinux --disabled,selinux --permissive,' | sed 's,rootpw --iscrypted \$default_password_crypted,rootpw --iscrypted \$default_password_crypted\nuser --groups=wheel --name=fedora --password=\$default_password_crypted --iscrypted --gecos="fedora",' | tee /var/lib/cobbler/templates/${PROFILE}.ks
        echo "[Import ISO] Updating profile $PROFILE"
        cobbler profile edit --name ${PROFILE} --autoinstall ${PROFILE}.ks
        echo "[Import ISO] Profile $PROFILE updated successfully"
    done
fi

#####################
#   Ubuntu Server   #
#####################

PROFILE_NAME="Ubuntu-Server-2004"
echo "[Import ISO] Importing "$PROFILE_NAME""
cobbler import --name="$PROFILE_NAME"  --path /mnt/ubuntu-server-2004 --arch=x86_64
cp -r /isos/cloud-init/Ubuntu20/ /var/www/cobbler/pub/cloud-init/Ubuntu20/
if [[ $? -eq 0 ]]; then
    for PROFILE in $(cobbler profile list | grep "$PROFILE_NAME");do
        echo "[Import ISO] Updating kernel options for Ubuntu 20.04 profile to support autoinstall with cloud-init"
        cobbler profile edit \
                --name ${PROFILE}  \
                --autoinstall cloud-init_user-data \
                --kernel-options "root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://${COBBLER_SERVER_HOST}/cblr/pub/cloud-init/Ubuntu20/ubuntu-20.04.6-live-server-amd64.iso autoinstall cloud-config-url=http://${COBBLER_SERVER_HOST}/cblr/svc/op/autoinstall/profile/$PROFILE"
        echo "[Import ISO] Profile $PROFILE updated successfully"
    done
fi


###################
#   Rocky Linux   #
###################

PROFILE_NAME="Rocky-9.7-Base"
echo "[Import ISO] Importing "$PROFILE_NAME""
cobbler import --name="$PROFILE_NAME"  --path /mnt/rocky-9 --arch=x86_64
if [[ $? -eq 0 ]]; then
    for PROFILE in $(cobbler profile list | grep "$PROFILE_NAME");do
        echo "[Import ISO] Creating generic ks file for $PROFILE"
        cat /var/lib/cobbler/templates/rocky-linux.ks | sed 's,selinux --disabled,selinux --permissive,' | tee /var/lib/cobbler/templates/${PROFILE}.ks
        echo "[Import ISO] Updating profile $PROFILE"
        cobbler profile edit --name ${PROFILE} --autoinstall ${PROFILE}.ks
        echo "[Import ISO] Profile $PROFILE updated successfully"
    done
fi

echo "[Import ISO] Restarting cobblerd service to apply changes"
supervisorctl restart cobblerd
echo "[Import ISO] Running cobbler sync..."
cobbler sync
