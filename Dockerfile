# https://github.com/EsDeKa/gameserverl4d2

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

USER root
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl git python3 \
        libc6:i386 libstdc++6:i386 lib32gcc-s1 lib32stdc++6 lib32z1 \
        libncurses5:i386 zlib1g:i386 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -d /home/steam -s /bin/bash -m steam
USER steam

RUN mkdir -p /home/steam/steamcmd && \
    cd /home/steam/steamcmd && \
    curl -o steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar zxf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

RUN mkdir -p /home/steam/.steam/sdk32 && \
    ln -sf /home/steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so


# Env - Defaults
ENV SRCDS_PORT=27015
# Env - Server
ENV SRCDS_SRV_DIR=/home/steam/left4dead2
ENV SRCDS_APP_ID=222860
ENV SERVER_NAME=SDK
# Env - SourceMod & MetaMod
ENV SOURCEMOD_VERSION_MAJOR=1.12
ENV SOURCEMOD_VERSION_MINOR=0
ENV SOURCEMOD_BUILD=7246
ENV METAMOD_VERSION_MAJOR=1.12
ENV METAMOD_VERSION_MINOR=0
ENV METAMOD_BUILD=1225

# Auto workshop collection downloader
ENV COLLECTIONS="2787108777 2787147130"

# Add start scripts
USER steam
RUN mkdir -p ${SRCDS_SRV_DIR}
COPY --chown=steam:steam resources/root/ /home/steam/
RUN chmod +x /home/steam/start.sh /home/steam/runServer_.sh

# Expose Ports
EXPOSE ${SRCDS_PORT}
EXPOSE ${SRCDS_PORT}/udp

# Start Server

ENTRYPOINT ["/home/steam/start.sh"]
CMD ["+map c7m2_barge +ip 0.0.0.0 +precache_all_survivors 1"]

# Debugging:
# docker run -it --name "esdekal4d2" -v $PWD/content:/home/steam/left4dead2 -p 27035:27035 -p 27035:27035/udp --env SRCDS_PORT=27035 --env SERVER_NAME="SDK_TEST_SERVER" --rm --entrypoint /bin/bash esdeka/gameserverl4d2 