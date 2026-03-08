# Cobbler 3.3.7 with Docker

This repository contains Dockerfile and docker-compose configuration to run Cobbler 3.3.7 in a container-based solution. It also contains scripts to download and import iso images.

It is based on the [Cobbler v.3.3.6 Beginner's Guide](https://cobbler.github.io/blog/2024/11/12/Cobbler-v3.3.6-Beginners-Guide.html) adapter to Docker and updated to Cobbler 3.3.7.


## Prerequisites
- Docker
- Docker-compose
- Internet connection to download iso images

## Setup Cobbler

- Setup the environment variables in `docker-compose.yml` file according to your network configuration. Below is an example:

```yml
COBBLER_SERVER_HOST: 10.17.3.1
COBBLER_NEXT_SERVER_HOST: 10.17.3.1
COBBLER_SUBNET: 10.17.3.0
COBBLER_NETMASK: 255.255.255.0
COBBLER_ROUTERS: 10.17.3.1
COBBLER_NAMESERVERS: 1.1.1.1,8.8.8.8
COBBLER_DHCP_RANGE: 10.17.3.50 10.17.3.100
COBBLER_ETH_INTERFACE: virbr2
COBBLER_PXE_JUST_ONE: "true"
COBBLER_ENABLE_IPXE: "true"
COBBLER_ETH_INTERFACE: enp0s3
TZ: America/Sao_Paulo
```

| Variable | Description |
| --- | --- |
| COBBLER_SERVER_HOST | IP address or hostname of the Cobbler server |
| COBBLER_NEXT_SERVER_HOST | IP address of the TFTP server (usually the same as Cobbler server) |
| COBBLER_SUBNET | Subnet for DHCP configuration |
| COBBLER_NETMASK | Netmask for DHCP configuration |
| COBBLER_ROUTERS | Default gateway for DHCP clients |
| COBBLER_NAMESERVERS | DNS servers for DHCP clients |
| COBBLER_DHCP_RANGE | Range of IP addresses to be assigned to DHCP clients |
| COBBLER_ETH_INTERFACE | Network interface to be used for DHCP and TFTP services |
| COBBLER_PXE_JUST_ONE | If set to "true", only one PXE client will be allowed to boot at a time |
| COBBLER_ENABLE_IPXE | If set to "true", iPXE will be enabled for network booting |
| COBBLER_ETH_INTERFACE | Network interface to be used for DHCP and TFTP services |
| TZ | Timezone for the container |

- Save the `cobbler_root_password` in a `cobbler_root_password.txt` file to be read by the docker secret.

```bash
echo -n "your_secure_password" > secret/cobbler_root_password.txt
chmod 600 secret/cobbler_root_password.txt
```

- Start the Cobbler server using Docker-compose.

```bash
docker-compose up -d
```

- Execute the `render_dhcp_files.sh` script to generate the necessary DHCP configuration files.

> The non-Docker Cobbler installation relay on *systemd* to start and manage services. In this Docker-based solution, we use `supervisord` to manage the services in a similar way. However, as `cobbler` expect systemd to be present, we need to enable temporary DHCP, to generate the necessary configuration files and then disable it to avoid showing errors because of the missing systemd. The `render_dhcp_files.sh` script will do this for you.

```bash
render_dhcp_files.sh
```

- Create the bootable GRUB2 booloaders in EFI format

```bash
cobbler sync && sleep 5
cobbler check
cobbler mkloaders
```

- Finally, full the latest Cobbler signatures and restart the services

```bash
cobbler signature update
supervisorctl restart cobblerd && sleep 5
cobbler sync
```

## Using Cobbler for deployment

In the following sections, we will cover how to use Cobbler for deployment using Fedora 34 as example.

- On the host, download the Fedora 34 iso image and mount it to `/mnt` directory.

```bash
mkdir -p /mnt/fedora-34
curl -L -o /tmp/Fedora-Server-dvd-x86_64-34-1.2.iso https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/34/Server/x86_64/iso/Fedora-Server-dvd-x86_64-34-1.2.iso
sudo mount -t iso9660 -o loop,ro /tmp/Fedora-Server-dvd-x86_64-34-1.2.iso /mnt/fedora-34
```

- Inside the container, import the mounted iso image to Cobbler using the `cobbler import` command.

```bash
cobbler import --name=Fedora34 --path=/mnt/fedora-34 --arch=x86_64
```

- Optionally, inspect the imported distribution and the child profile.

```bash
cobbler distro report --name=Fedora34-x86_64
cobbler profile report --name=Fedora34-x86_64
```

- Create a generic kickstart for Fedora 34 using the default `sample.ks` file provided by Cobbler.

```bash
cat /var/lib/cobbler/templates/sample.ks | grep -v "\--useshadow" | grep -v ^install | sed 's,selinux --disabled,selinux --permissive,' | sed 's,rootpw --iscrypted \$default_password_crypted,rootpw --iscrypted \$default_password_crypted\nuser --groups=wheel --name=fedora --password=\$default_password_crypted --iscrypted --gecos="fedora",' | tee /var/lib/cobbler/templates/Fedora34.ks
cobbler profile edit --name Fedora34-x86_64 --autoinstall Fedora34.ks
```

> The above command will create a new kickstart file based on the `sample.ks` file, with some additions such as creating a user named `fedora` with the `$cobbler_root_password` set before, disabling SELinux, and removing some options that cause fatal errors.

- Add the new kickstart file to the profile and sync Cobbler.
```bash
cobbler profile add --name=Fedora34-x86_64 --distro=Fedora34-x86_64 --kickstart=/var/lib/cobbler/kickstarts/sample.ks
supervisorctl restart cobblerd
cobbler sync
```

- Finally, create a new system in Cobbler and boot it using PXE.

```bash
cobbler system add --name=fedora34-test --profile=Fedora34-x86_64 --netboot-enabled true --hostname fedora34
``` 




