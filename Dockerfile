FROM fedora:34

ARG COBBLER_GIT_URL="https://github.com/cobbler/cobbler.git"
ARG COBBLER_GIT_TAG="v3.3.7"

ENV COBBLER_SERVER_HOST=127.0.0.1 \
    COBBLER_NEXT_SERVER_HOST=127.0.0.1 \
    COBBLER_PUBLIC_SSH_KEY= \
    COBBLER_SUBNET=192.168.10.0 \
    COBBLER_NETMASK=255.255.255.0 \
    COBBLER_ROUTERS=192.168.10.1 \
    COBBLER_NAMESERVERS=1.1.1.1,8.8.8.8 \
    COBBLER_DHCP_RANGE="192.168.10.50 192.168.10.100" \
    COBBLER_PROXY_URL_EXT= \
    COBBLER_PROXY_URL_INT= \
    COBBLER_ETH_INTERFACE=eth0

RUN dnf makecache

# Dev dependencies
RUN dnf install -y           \
    git                      \
    rsync                    \
    make                     \
    curl                     \
    wget2                    \
    openssl                  \
    mod_ssl                  \
    initscripts             \
    python-sphinx           \
    python3-coverage        \
    python3-devel           \
    python3-wheel           \
    python3-distro          \
    python3-pyflakes        \
    python3-pycodestyle     \
    python3-setuptools      \
    python3-sphinx          \
    python3-pip             \
    rpm-build               \
    which                   \
    httpd-devel

# Runtime dependencies
RUN yum install -y          \
    httpd                   \
    python3-mod_wsgi        \
    python3-PyYAML          \
    python3-cheetah         \
    python3-netaddr         \
    python3-dns             \
    python3-file-magic      \
    python3-ldap            \
    python3-librepo         \
    python3-pymongo         \
    python3-schema          \
    createrepo_c            \
    dnf-plugins-core        \
    xorriso                 \
    grub2-efi-ia32-modules  \
    grub2-efi-x64-modules   \
    logrotate               \
    syslinux                \
    tftp-server             \
    fence-agents            \
    openldap-servers        \
    openldap-clients        \
    supervisor              \
    dosfstools              \
    dhcp-server             \
    pykickstart             \
    ipxe-bootimgs           \
    ipxe-roms               \
    koan                    

# Bootloader dependencies
RUN dnf install -y          \
    grub2-pc                \
    grub2-pc-modules        \
    grub2-efi-x64-modules   \
    grub2-efi-aa64-modules  \
    grub2-efi-arm-modules   \
    grub2-efi-ia32-modules  \
    grub2-emu-modules       \
    grub2-emu-modules       \
    grub2-ppc64le-modules   \
    grub2-emu

# Utilities
RUN dnf install -y          \
    vim                     \
    net-tools            && \
    pip3 install --no-cache-dir j2cli[yaml]
    

# Install Cobbler from source
RUN git clone ${COBBLER_GIT_URL} /tmp/cobbler && \
    cd /tmp/cobbler && \
    git checkout ${COBBLER_GIT_TAG} && \
    make install && \
    rm -rf /tmp/cobbler

# Symlink undionly.kpxe to Cobbler TFTP loaders directory for iPXE support
RUN ln -s /usr/share/ipxe/undionly.kpxe /var/lib/cobbler/loaders/undionly.kpxe

RUN rm -f /etc/httpd/conf.d/ssl.conf 

# Create directory for cloud-init ISOs
RUN mkdir -p /var/www/cobbler/pub/cloud-init/

# Configs & scripts
COPY configs/ /

EXPOSE 80 443 69/udp

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]