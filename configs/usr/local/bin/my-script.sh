#!/usr/bin/env bash

supervisorctl restart cobblerd && sleep 10
cobbler sync && sleep 5
cobbler check
cobbler mkloaders


cobbler signature update
supervisorctl restart cobblerd && sleep 5
cobbler sync

cobbler system add --name Fedora34 --profile Fedora34-x86_64 --mac-adress "aa:bb:cc:dd:ee:ff" --netboot-enabled true --hostname fedora34 --interface enp0s3 --static true --ip-address 10.0.0.11 --gateway 10.0.0.1 --netmask 255.255.255.0 --name-servers "10.0.0.1"
systemctl restart cobblerd && sleep 10
cobbler sync