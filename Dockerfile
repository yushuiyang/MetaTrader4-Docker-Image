FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye-8446af38-ls104

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Metatrader Docker:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="gmartin"

ENV TITLE="MetaTrader4"
ENV WINEPREFIX="/config/.wine"

# 1. 适配 Debian 11 (Bullseye) 的归档源，剔除已失效的 backports，并跳过全局 upgrade 避免 404
RUN rm -f /etc/apt/sources.list.d/nodesource.list /etc/apt/sources.list.d/nodesource.sources && \
    echo "deb http://archive.debian.org/debian bullseye main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list && \
    sed -i '/bullseye-backports/d' /etc/apt/sources.list && \
    echo "Acquire::Check-Valid-Until \"false\";" > /etc/apt/apt.conf.d/99no-check-valid-until && \
    apt-get update && \
    apt-get install -y \
        python3-pip \
        wget \
        gnupg2 \
        software-properties-common \
        ca-certificates && \
    pip3 install --upgrade pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. 使用现代化推荐的 gpg 方式添加 WineHQ 仓库密钥，避免已废弃的 apt-key 报错
RUN dpkg --add-architecture i386 \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key \
    && echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/debian/ bullseye main" > /etc/apt/sources.list.d/winehq.list \
    && apt-get update

# 3. 安装 WineHQ stable 及所需依赖
RUN apt-get install --install-recommends -y \
    winehq-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY /Metatrader /Metatrader
RUN chmod +x /Metatrader/start.sh
COPY /root /

EXPOSE 3000 8001
VOLUME /config
