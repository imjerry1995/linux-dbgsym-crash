FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    wget \
    make \
    gcc \
    libgmp-dev \
    libmpfr-dev \
    texinfo \
    bison \
    libncurses-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/crash-utility/crash/archive/refs/tags/9.0.1.tar.gz && \
    tar -zxvf 9.0.1.tar.gz && \
    cd crash-9.0.1 && \
    make && \
    cp crash /tmp/crash-bin

RUN wget http://ddebs.ubuntu.com/pool/main/l/linux-hwe-6.17/linux-image-unsigned-6.17.0-20-generic-dbgsym_6.17.0-20.20~24.04.1_amd64.ddeb && \
    dpkg -x linux-image-unsigned-6.17.0-20-generic-dbgsym_6.17.0-20.20~24.04.1_amd64.ddeb /tmp/extracted && \
    rm linux-image-unsigned-6.17.0-20-generic-dbgsym_6.17.0-20.20~24.04.1_amd64.ddeb

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    libncurses6 \
    liblzo2-2 \
    libsnappy1v5 \
    libzstd1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/crash-bin /usr/local/bin/crash
COPY --from=builder /tmp/extracted/usr/lib/debug/boot/vmlinux-6.17.0-20-generic \
    /usr/lib/debug/boot/vmlinux-6.17.0-20-generic

CMD ["bash"]
