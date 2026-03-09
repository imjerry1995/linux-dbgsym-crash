FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends dpkg

COPY linux-image-unsigned-6.8.0-52-generic-dbgsym_6.8.0-52.53~22.04.1_amd64.ddeb /tmp/

RUN dpkg -x /tmp/linux-image-unsigned-6.8.0-52-generic-dbgsym_6.8.0-52.53~22.04.1_amd64.ddeb /tmp/extracted && \
	rm /tmp/linux-image-unsigned-6.8.0-52-generic-dbgsym_6.8.0-52.53~22.04.1_amd64.ddeb

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends crash

COPY --from=builder /tmp/extracted/usr/lib/debug/boot/vmlinux-6.8.0-52-generic /usr/lib/debug/boot/vmlinux-6.8.0-52-generic

CMD ["bash"]
