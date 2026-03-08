if [ ! -f "/usr/local/bin/cobbler" ]; then
  echo "This script should only be run in container, execute:"
  echo "\$ docker exec -it new-cobbler-cobbler-1 /bin/bash -c \"\$(<import-iso.sh)\""
  exit 1
fi

PROFILE_NAME="Fedora-Server-dvd-x86_64-34-1.2-server"
echo "Importing ${PROFILE_NAME}"
cobbler import --name="$PROFILE_NAME"  --path /mnt/fedora-34 --arch=x86_64 --breed fedora
if [[ $? -eq 0 ]]; then
    for PROFILE in $(cobbler profile list | grep ${PROFILE_NAME});do
        echo "Updating profile $PROFILE"
        cobbler profile edit \
          --name ${PROFILE}  \
          --kernel-options="ksdevice=bootif lang priority=critical locale=en_US text netcfg/dhcp_timeout=60 netcfg/choose_interface=auto console=tty0"
    done
fi

echo "Running cobbler sync"
cobbler sync
