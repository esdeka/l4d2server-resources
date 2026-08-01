#!/bin/bash

cd ${SRCDS_SRV_DIR}

# Check if MetaMod needs to be downloaded
if [ ! -d "left4dead2/addons/metamod" ] || [ ! -f "mm-version" ] || [ "${METAMOD_VERSION_MAJOR}.${METAMOD_VERSION_MINOR}-${METAMOD_BUILD}" != $(head -n 1 mm-version) ]; then
    echo "Downloading MetaMod"
    curl -sSL https://mms.alliedmods.net/mmsdrop/$METAMOD_VERSION_MAJOR/mmsource-$METAMOD_VERSION_MAJOR.$METAMOD_VERSION_MINOR-git$METAMOD_BUILD-linux.tar.gz \
        -o /tmp/metamod.tar.gz
    mkdir /tmp/metamod
    tar -xzvf /tmp/metamod.tar.gz --directory /tmp/metamod
    chmod +777 -R /tmp/metamod
    cp -pR /tmp/metamod/* $SRCDS_SRV_DIR/left4dead2
    rm -R /tmp/metamod*
    echo "${METAMOD_VERSION_MAJOR}.${METAMOD_VERSION_MINOR}-${METAMOD_BUILD}" > mm-version
fi

getSourceMod="false"
# Check if SourceMod needs to be downloaded
if [ ! -d "left4dead2/addons/sourcemod" ] || [ ! -f "sm-version" ] || [ "${SOURCEMOD_VERSION_MAJOR}.${SOURCEMOD_VERSION_MINOR}-${SOURCEMOD_BUILD}" != $(head -n 1 sm-version) ]; then
    getSourceMod="true"
    echo "Downloading SourceMod"
    curl -sSL https://sm.alliedmods.net/smdrop/$SOURCEMOD_VERSION_MAJOR/sourcemod-$SOURCEMOD_VERSION_MAJOR.$SOURCEMOD_VERSION_MINOR-git$SOURCEMOD_BUILD-linux.tar.gz \
        -o /tmp/sourcemod.tar.gz
    mkdir /tmp/sourcemod
    tar -xzvf /tmp/sourcemod.tar.gz --directory /tmp/sourcemod
    chmod +777 -R /tmp/sourcemod
    cp -pR /tmp/sourcemod/* $SRCDS_SRV_DIR/left4dead2
    rm -R /tmp/sourcemod*
    echo "${SOURCEMOD_VERSION_MAJOR}.${SOURCEMOD_VERSION_MINOR}-${SOURCEMOD_BUILD}" > sm-version
fi

# Pull EsDeKa resources
if [ "$getSourceMod" = "true" ]; then
    echo "Cloning resources:"
    git clone https://github.com/EsDeKa/l4d2server-resources.git
    cp -R l4d2server-resources/. .
    rm -R --interactive=never l4d2server-resources/
fi

# Disable plugins
if [ -f "left4dead2/addons/sourcemod/plugins/nextmap.smx" ];then
    echo "Disabling useless nextmap.smx"
    mv left4dead2/addons/sourcemod/plugins/nextmap.smx left4dead2/addons/sourcemod/plugins/disabled/
fi

# Configure server name in separate cfg file
echo hostname \"${SERVER_NAME:-SDK}\" > left4dead2/cfg/private_env.cfg

# Run Server

echo "-----------steamcmd update -----------"
/home/steam/steamcmd/steamcmd.sh +login anonymous   \
        +force_install_dir ${SRCDS_SRV_DIR}         \
        +app_update ${SRCDS_APP_ID}                 \
        +quit

if [ -v COLLECTIONS ]; then
    echo "-----------Syncing with workshop.py-----------"
    python3 /home/steam/workshop.py                     \
        -o ~/left4dead2/left4dead2/addons/workshop/     \
        ${COLLECTIONS}
fi
        
echo "-----------Starting srcds_run-----------"
./srcds_run                                         \
    -game left4dead2                                \
    -console                                        \
    -usercon                                        \
    -steam_dir /home/steam/steamcmd                 \
    -steamcmd_script /home/steam/autoupdate.txt     \
    -port ${SRCDS_PORT}                             \
    $@
