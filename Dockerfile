FROM i386/ubuntu:18.04
MAINTAINER Will Abele <will.abele@starlab.io>

ENV DEBIAN_FRONTEND=noninteractive
ENV USER root

# build depends
RUN apt-get update && \
    apt-get --quiet --yes install \
        build-essential pkg-config ca-certificates curl wget git libssl-dev \
        software-properties-common gcc-multilib python2.7-dev bc \
        python-pip python-virtualenv check linux-headers-generic \
        apt-transport-https && \
        apt-get autoremove -y && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*

# Add the proxy cert (needs to come after ca-certificates installation)
ADD proxy.crt /usr/local/share/ca-certificates/proxy.crt
RUN chmod 644 /usr/local/share/ca-certificates/proxy.crt
RUN update-ca-certificates --fresh

# where we build
RUN mkdir /source
VOLUME ["/source"]
WORKDIR /source
CMD ["/bin/bash"]

RUN mkdir -p /root/.cargo/
RUN echo "[target.i686-unknown-linux-musl]\r\n rustflags = [\"-C\", \"link-args=/usr/lib/i386-linux-musl/libc.a\"]" >> /root/.cargo/config

ENV PATH "/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# install rustup
RUN curl https://sh.rustup.rs -sSf > rustup-install.sh && \
    sh ./rustup-install.sh -y --default-toolchain 1.37.0-x86_64-unknown-linux-gnu && \
    rm rustup-install.sh

RUN /root/.cargo/bin/rustup target add i686-unknown-linux-musl

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        acpica-tools \
        autoconf-archive \
        bc \
        bcc \
        bin86 \
        checkpolicy \
        clang \
        clang-format \
        clang-tools \
        cmake \
        dos2unix \
        gawk \
        gettext \
        gnu-efi \
        lcov \
        libaio-dev \
        libbsd-dev \
        libbz2-dev \
        libcmocka-dev \
        libkeyutils-dev \
        liblzma-dev \
        libncurses-dev \
        libnl-3-dev \
        libnl-cli-3-dev \
        libnl-utils \
        libpci-dev \
        libtool \
        libtspi-dev \
        libyajl-dev \
        linux-headers-generic \
        m4 \
        ncurses-dev \
        parallel \
        rpm \
        software-properties-common \
        texinfo \
        u-boot-tools \
        uuid-dev \
        musl-tools \
        vim-common && \
        apt-get autoremove -y && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*

RUN ln -s /usr/include/asm-generic/ /usr/include/i386-linux-musl/asm-generic
RUN ln -s /usr/include/i386-linux-gnu/asm/ /usr/include/i386-linux-musl/asm
RUN ln -s /usr/include/linux /usr/include/i386-linux-musl/linux
