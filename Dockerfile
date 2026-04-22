FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye-8446af38-ls104

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Metatrader Docker:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="gmartin"

ENV TITLE="MetaTrader4"
ENV WINEPREFIX="/config/.wine"
ENV WINEDEBUG="-all"

# --- 核心修复：清理所有失效的第三方源（包括 NodeSource 和 Backports） ---
RUN rm -f /etc/apt/sources.list.d/*.list && \
    sed -i '/bullseye-backports/d' /etc/apt/sources.list && \
    apt-get update && apt-get upgrade -y

# Install required packages
# 注意：Debian Bullseye 下建议直接安装 python3-pip
RUN apt-get install -y --no-install-recommends \
    python3-pip \
    wget \
    gnupg2 \
    ca-certificates \
    fonts-wqy-microhei \
    software-properties-common && \
    pip3 install --upgrade pip

# --- 修复 2：添加 Wine 仓库 ---
RUN dpkg --add-architecture i386 && \
    mkdir -pm 755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources

# --- 修复 3：安装 Wine (建议 staging 以获得更好的 MT4 兼容性) ---
RUN apt-get update && \
    apt-get install --install-recommends -y \
    winehq-staging && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY /Metatrader /Metatrader
RUN chmod +x /Metatrader/start.sh
COPY /root /

EXPOSE 3000 8001
VOLUME /config
