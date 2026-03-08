# Cobbler 3.3.7 with Docker

This repository provides a **Dockerfile** and a **Docker Compose configuration** for running **Cobbler 3.3.7** inside a container. It also includes helper scripts to download and import ISO images, along with predefined autoinstall templates for **Fedora**, **Ubuntu**, and **Rocky Linux**.

The setup is primarily based on the [Cobbler v3.3.6 Beginner's Guide](https://cobbler.github.io/blog/2024/11/12/Cobbler-v3.3.6-Beginners-Guide.html) and builds upon the work by [urosorozel](https://github.com/urosorozel/docker-cobbler/tree/master).


## Table of Contents

- [Prerequisites](#prerequisites)
- [1. Setting Up Cobbler](#1-setting-up-cobbler)
  - [1.1 Configure Environment Variables](#11-configure-environment-variables)
  - [1.2 Configure the Cobbler Root Password](#12-configure-the-cobbler-root-password)
  - [1.3 Start the Cobbler Server](#13-start-the-cobbler-server)
  - [1.4 Download ISO Images and Mount Them on the Host](#14-download-iso-images-and-mount-them-on-the-host)
  - [1.5 Import ISO Images and Create Profiles](#15-import-iso-images-and-create-profiles)
  - [1.6 Check the Imported Distributions and Profiles](#16-check-the-imported-distributions-and-profiles)
- [2. Using the Cobbler Container](#2-using-the-cobbler-container)
  - [2.1 Fedora 34 Deployment](#21-fedora-34-deployment)
  - [2.2 Ubuntu 20.04, 22.04, and 24.04 Deployment](#22-ubuntu-2004-2204-and-2404-deployment)
  - [2.3 Rocky Linux 9 and 10 Deployment](#23-rocky-linux-9-and-10-deployment)
- [3. Testing Using KVM Virtual Machines](#3-testing-using-kvm-virtual-machines)
  - [3.1 Preparing a Virtual Network for the VM](#31-preparing-a-virtual-network-for-the-vm)
  - [3.2 Verify the Network Definition](#32-verify-the-network-definition)
  - [3.3 Start the Network](#33-start-the-network)
  - [3.4 Enable Automatic Startup (Optional)](#34-enable-automatic-startup-optional)
  - [3.5 Creating a System in Cobbler](#35-creating-a-system-in-cobbler)
  - [3.6 Create and Boot a Virtual Machine](#36-create-and-boot-a-virtual-machine)
- [4. Further Reading](#4-further-reading)

---

# Prerequisites

Before starting, ensure the following are installed on your system:

- Docker
- Docker Compose
- An active Internet connection (required to download ISO images)

---

# 1. Setting Up Cobbler

## 1.1 Configure Environment Variables

Create a `.env` file using the provided example:

```bash
cp .env.example .env
```

Then edit the `.env` file and adjust the values according to your environment.

| Variable | Description |
|----------|-------------|
| `COBBLER_SERVER_HOST` | IP address or hostname of the Cobbler server |
| `COBBLER_NEXT_SERVER_HOST` | IP address of the TFTP server (usually the same as the Cobbler server) |
| `COBBLER_SUBNET` | Subnet used for DHCP configuration |
| `COBBLER_NETMASK` | Netmask used for DHCP configuration |
| `COBBLER_ROUTERS` | Default gateway provided to DHCP clients |
| `COBBLER_NAMESERVERS` | DNS servers provided to DHCP clients |
| `COBBLER_DHCP_RANGE` | IP address range assigned to DHCP clients |
| `COBBLER_PXE_JUST_ONE` | If set to `true`, only one PXE client can boot at a time |
| `COBBLER_ENABLE_IPXE` | Enables iPXE network booting when set to `true` |
| `COBBLER_MANAGE_DHCP` | Enables DHCP management by Cobbler |
| `COBBLER_MANAGE_DHCP_V4` | Enables DHCPv4 management by Cobbler |
| `COBBLER_DEFAULT_USERNAME` | Default username for the Cobbler server |
| `COBBLER_DEFAULT_SSH_KEY` | Default SSH public key for the root user |
| `TZ` | Timezone used inside the container |

---

## 1.2 Configure the Cobbler Root Password

Store the Cobbler root password in a file that will be used as a Docker secret.

```bash
echo -n "your_secure_password" > secret/cobbler_root_password.txt
chmod 600 secret/cobbler_root_password.txt
```

Ensure the file permissions are restricted so that only the owner can read it.

---

## 1.3 Start the Cobbler Server

Start the services using Docker Compose:

```bash
docker-compose up -d
```

This command builds the image (if needed) and launches the Cobbler server in the background.

---

## 1.4 Download ISO Images and Mount Them on the Host

On the host machine, download the ISO images for Fedora, Ubuntu, and Rocky Linux using the `download-iso-and-mount.sh` script.

```bash
./download-iso-and-mount.sh
```

This script downloads the ISO files for Fedora, Ubuntu, and Rocky Linux and stores them in the `isos` directory. The generated tree structure will look like this:

```txt
isos
├── cloud-init
│   ├── Rocky-9.7-x86_64-dvd.iso
│   ├── ubuntu-16.04.6-server-amd64.iso
│   ├── ubuntu-18.04.3-server-amd64.iso
│   ├── Ubuntu20
│   │   └── ubuntu-20.04.6-live-server-amd64.iso
│   ├── Ubuntu22
│   │   └── ubuntu-22.04.5-live-server-amd64.iso
│   └── Ubuntu24
│       └── ubuntu-24.04.4-live-server-amd64.iso
├── Fedora
│   └── Fedora-Server-dvd-x86_64-34-1.2.iso
└── Rocky
    ├── Rocky-10.1-x86_64-dvd1.iso
    └── Rocky-9.7-x86_64-dvd.iso
```

Additionally, the script mounts the downloaded ISO images under `/mnt` on the host. The mounted directories will then be accessible inside the Cobbler container for importing.

---

## 1.5 Import ISO Images and Create Profiles

Now you need to import the mounted ISO images into Cobbler and create the corresponding profiles. This can be done by running the `import-iso.sh` script inside the container.

**Note:** Ensure the `cobblerd`, `httpd`, and `tftpd` services are running before executing the script.

You can check the status of the services with:

```bash
docker exec -it cobbler-3.7 supervisorctl status
```

Expected output:

```txt
$ docker exec -it cobbler-3.7 supervisorctl status
cobblerd                         RUNNING   pid 663, uptime 1:54:35
dhcpd                            RUNNING   pid 4849, uptime 0:23:15
httpd                            RUNNING   pid 7, uptime 1:56:26
tftpd                            RUNNING   pid 8, uptime 1:56:26
update-config                    EXITED    Mar 07 07:31 PM
```

After confirming the services are running, execute:

```bash
docker exec -it cobbler-3.7 /bin/bash -c "$(cat import-iso.sh)"
```

This script will:

- Import the mounted ISO images into Cobbler
- Create distributions and profiles
- Configure autoinstallation using **cloud-init** for each profile

---

## 1.6 Check the Imported Distributions and Profiles

You can verify the imported distributions and profiles using the Cobbler CLI:

```bash
docker exec -it cobbler-3.7 cobbler distro list
docker exec -it cobbler-3.7 cobbler profile list
```

Example output:

```txt
$ docker exec -it cobbler-3.7 cobbler distro list
   Fedora-Server-34-x86_64
   Rocky-10.1-Base-x86_64
   Rocky-9.7-Base-x86_64
   Ubuntu-Server-2004-casper-x86_64
   Ubuntu-Server-2204-casper-x86_64
   Ubuntu-Server-2404-casper-x86_64
```

---

# 2. Using the Cobbler Container

You can now use the imported distributions and profiles to deploy new systems with Cobbler.

In the following examples, we use the predefined autoinstall files included in this repository. However, you can also create your own autoinstall configurations (such as **Kickstart** or **cloud-init**) and associate them with the appropriate profiles.

First, enter the Cobbler container:

```bash
docker exec -it cobbler-3.7 /bin/bash
```

---

## 2.1 Fedora 34 Deployment

You can deploy a new system using the `Fedora-Server-34-x86_64` profile created in the previous steps:

```bash
cobbler system add --name=<system_name> --profile=Fedora-Server-34-x86_64 --netboot-enabled true <cobbler options>
```

Example:

```bash
cobbler system add --name=fedora34-test --profile=Fedora-Server-34-x86_64 --netboot-enabled true --hostname fedora37 --interface enp0s3 --static true --ip-address 10.17.3.52 --gateway 10.17.3.1 --netmask 255.255.255.0 --name-servers "8.8.8.8 1.1.1.1"
```

---

## 2.2 Ubuntu 20.04, 22.04, and 24.04 Deployment

Example commands:

```bash
# Ubuntu 20.04
NAME=<system_name>
cobbler system add --name=$NAME --profile=Ubuntu-Server-2004-casper-x86_64 --netboot-enabled true --kernel-options "root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://${COBBLER_SERVER_HOST}/cblr/pub/cloud-init/Ubuntu20/ubuntu-20.04.6-live-server-amd64.iso autoinstall cloud-config-url=http://${COBBLER_SERVER_HOST}/cblr/svc/op/autoinstall/system/$NAME" <cobbler options>
```

Example:

```bash
NAME=my-ubuntu-20-04
cobbler system add --name=$NAME --profile=Ubuntu-Server-2004-casper-x86_64 --netboot-enabled true --kernel-options "root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://${COBBLER_SERVER_HOST}/cblr/pub/cloud-init/Ubuntu20/ubuntu-20.04.6-live-server-amd64.iso autoinstall cloud-config-url=http://${COBBLER_SERVER_HOST}/cblr/svc/op/autoinstall/system/$NAME" --mac-address "aa:bb:cc:dd:ee:ff" --static true --ip-address "10.17.3.52" --netmask "255.255.255.0" --gateway "10.17.3.1" --name-servers "8.8.8.8 1.1.1.1" --hostname "Ubuntu22"
```

---

## 2.3 Rocky Linux 9 and 10 Deployment

```bash
# Rocky Linux 9
cobbler system add --name=<system_name> --profile=Rocky-9.7-Base-x86_64 --netboot-enabled true <cobbler options>

# Rocky Linux 10
cobbler system add --name=<system_name> --profile=Rocky-10.1-Base-x86_64 --netboot-enabled true <cobbler options>
```

Example:

```bash
cobbler system add --name=rocky9-test --profile=Rocky-9.7-Base-x86_64 --netboot-enabled true --hostname rocky9-test --interface enp0s3 --static true --ip-address 10.17.3.52 --netmask 255.255.255.0 --gateway 10.17.3.1 --name-servers "8.8.8.8 1.1.1.1"
```

---

# 3. Testing Using KVM Virtual Machines

If you do not have physical machines available for testing, you can use **KVM virtual machines** to test the PXE boot and deployment process.

---

## 3.1 Preparing a Virtual Network for the VM

```bash
virsh net-define /dev/stdin <<'EOF'
<network>
    <name>cobbler</name>
    <forward mode='nat'/>
    <bridge name='virbr2' stp='on' delay='0'/>
    <domain name='cobbler.local'/>
    <dns enable='no'/>
    <ip family='ipv4' address='10.17.3.1' prefix='24'>
    </ip>
</network>
EOF
```

---

## 3.2 Verify the Network Definition

```bash
virsh net-list --all
```

---

## 3.3 Start the Network

```bash
virsh net-start cobbler
```

---

## 3.4 Enable Automatic Startup (Optional)

```bash
virsh net-autostart cobbler
```

---

## 3.5 Creating a System in Cobbler

```bash
docker exec -it cobbler-3.7 cobbler system add --name=fedora34-test --profile=Fedora-Server-34-x86_64 --netboot-enabled true --mac-address "00:11:22:33:44:55" --static true --ip-address 10.17.3.52 --gateway 10.17.3.1 --netmask 255.255.255.0 --name-servers "8.8.8.8 1.1.1.1"
```

---

## 3.6 Create and Boot a Virtual Machine

```bash
virt-install --connect qemu:///system \
                --name demo-fedora-34_x86 \
                --arch x86_64 \
                --vcpu 2 \
                --memory 4096 \
                --disk size=10 \
                --pxe \
                --network network=cobbler,mac=00:11:22:33:44:55 \
                --virt-type kvm \
                --console pty,target_type=serial \
                --graphics vnc,listen=0.0.0.0 \
                --os-variant fedora34
```

---

# 4. Further Reading


The following resources provide additional documentation and examples related to automated operating system installation and configuration. 

- [Kickstart Documentation](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)
- [Kickstart Samples for Rocky Linux](https://github.com/rocky-linux/kickstarts/)
- [Kickstart Files and Rocky Linux](https://docs.rockylinux.org/10/guides/automation/kickstart-rocky/)