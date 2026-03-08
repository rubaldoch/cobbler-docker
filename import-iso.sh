#!/bin/bash
if [ ! -f "/usr/local/bin/cobbler" ]; then
  echo "This script should only be run in container, execute:"
  echo "\$ docker exec -it cobbler-3.7 /bin/bash -c \"\$(<import-iso.sh)\""
  exit 1
fi

PROFILE_NAME="Fedora-Server-34-x86_64"
echo "[Import ISO] Importing ${PROFILE_NAME}"
cobbler import --name="$PROFILE_NAME"  --path /mnt/fedora-server-34 --arch=x86_64
if [[ $? -eq 0 ]]; then
    for PROFILE in $(cobbler profile list | grep ${PROFILE_NAME});do
        echo "[Import ISO] Creating generic ks file for $PROFILE"
        cat /var/lib/cobbler/templates/sample.ks | grep -v "\--useshadow" | grep -v ^install | sed 's,selinux --disabled,selinux --permissive,' | sed 's,rootpw --iscrypted \$default_password_crypted,rootpw --iscrypted \$default_password_crypted\nuser --groups=wheel --name=fedora --password=\$default_password_crypted --iscrypted --gecos="fedora",' | tee /var/lib/cobbler/templates/${PROFILE}.ks
        
        echo "[Import ISO] Updating profile $PROFILE"
        cobbler profile edit \
          --name ${PROFILE}  \
          --autoinstall ${PROFILE}.ks
        echo "[Import ISO] Profile $PROFILE updated successfully"
    done
fi

PROFILE_NAME="Ubuntu-Server-2004-x86_64"
echo "[Import ISO] Importing ${PROFILE_NAME}"
cobbler import --name="$PROFILE_NAME"  --path /mnt/ubuntu-server-2004 --arch=x86_64
cp -r /isos/cloud-init/Ubuntu20/ /var/www/cobbler/pub/cloud-init/Ubuntu20/
# Update kernel options for Ubuntu 20.04 profile to support autoinstall with cloud-init
cobbler distro edit --name $NAME --kernel-options "root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://${COBBLER_SERVER_HOST}/cblr/pub/cloud-init/Ubuntu20/ubuntu-20.04.6-live-server-amd64.iso autoinstall cloud-config-url=http://${COBBLER_SERVER_HOST}/cblr/svc/op/autoinstall/profile/$NAME" && unset NAME
sed -z 's,      uri: http://$http_server/cblr/links/$distro\n##      uri: http://us.archive.ubuntu.com/ubuntu,##      uri: http://$http_server/cblr/links/$distro\n      uri: http://us.archive.ubuntu.com/ubuntu,' /var/lib/cobbler/templates/cloud-init_user-data | tee /var/lib/cobbler/templates/${PROFILE_NAME}_cloud-init_user-data
echo "[Import ISO] Updating profile $PROFILE_NAME"
cobbler profile edit \
          --name ${PROFILE_NAME}  \
          --autoinstall ${PROFILE_NAME}_cloud-init_user-data \
          --kernel-options "root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://${COBBLER_SERVER_HOST}/cblr/pub/cloud-init/Ubuntu20/ubuntu-20.04.6-live-server-amd64.iso autoinstall cloud-config-url=http://${COBBLER_SERVER_HOST}/cblr/svc/op/autoinstall/system/$NAME"
echo "[Import ISO] Profile $PROFILE_NAME updated successfully"

echo "[Import ISO] Running cobbler sync"
supervisorctl restart cobblerd
cobbler sync
