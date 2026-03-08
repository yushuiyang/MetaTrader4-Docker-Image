FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye-8446af38-ls104

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Metatrader Docker:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="gmartin"

ENV TITLE="MetaTrader4"
ENV WINEPREFIX="/config/.wine"

# --- 修复 1：在 update 之前删除过期的 backports 源 ---
RUN sed -i '/bullseye-backports/d' /etc/apt/sources.list && \
    apt-get update && apt-get upgrade -y

# Install required packages
RUN apt-get install -y \
    python3-pip \
    wget \
    gnupg2 \
    software-properties-common \
    && pip3 install --upgrade pip

# --- 修复 2：使用更安全的方式添加 Wine 仓库（避开 apt-key 警告） ---
RUN dpkg --add-architecture i386 && \
    mkdir -pm 755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources

# --- 修复 3：更新源并安装 ---
RUN apt-get update && \
    apt-get install --install-recommends -y \
    winehq-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY /Metatrader /Metatrader
RUN chmod +x /Metatrader/start.sh
COPY /root /

EXPOSE 3000 8001
VOLUME /config
