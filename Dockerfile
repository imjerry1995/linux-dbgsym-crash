FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

# 安裝 build 依賴
RUN apt update && apt install -y --no-install-recommends \
    build-essential \
    wget \
    make \
    gcc \
    libgmp-dev \
    libmpfr-dev \
    texinfo \
    bison \
    libncurses-dev \
    && rm -rf /var/lib/apt/lists/*

# 下載 crash 9.0.1 source，預先放好 gdb tarball 可以在這裡 COPY 進來
RUN wget https://github.com/crash-utility/crash/archive/refs/tags/9.0.1.tar.gz && \
    tar -zxvf 9.0.1.tar.gz && \
    cd crash-9.0.1 && \
    make && \
    cp crash /tmp/crash-bin

# 下載 dbgsym ddeb 並解壓
RUN wget http://ddebs.ubuntu.com/pool/main/l/linux-hwe-6.17/linux-image-unsigned-6.17.0-20-generic-dbgsym_6.17.0-20.20~24.04.1_amd64.ddeb && \
    dpkg -x linux-image-unsigned-6.17.0-20-generic-dbgsym_6.17.0-20.20~24.04.1_amd64.ddeb /tmp/extracted && \
    rm linux-image-unsigned-6.17.0-20-generic-dbgsym_6.17.0-20.20~24.04.1_amd64.ddeb

# --- final image ---
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
