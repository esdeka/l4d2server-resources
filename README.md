# l4d2server-resources

Included in Docker image: https://github.com/EsDeKa/gameserverl4d2

Check .gitignore for used includes to add plugins

Also some manual stuff afterwards:  
- Create left4dead2/cfg/private.cfg as described in server.cfg
- Add whitelist groups to left4dead2/addons/sourcemod/configs/whitelist/whitelist.txt
- Change left4dead2/motd.txt
- Import bans:
  - left4dead2/cfg/banned_user.cfg
  - left4dead2/cfg/banned_ip.cfg
- [Accelerator](https://forums.alliedmods.net/showthread.php?t=277703) addons/sourcemod/configs/core.cfg  "MinidumpAccount"  "<insert your steamid here>"


[![Docker](https://github.com/EsDeKa/gameserverl4d2/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/EsDeKa/gameserverl4d2/actions/workflows/docker-publish.yml)

# L4D2 Docker Image

L4D2 Dedicated Server with Metamod & Sourcemod + [my personal plugin selection](https://github.com/EsDeKa/l4d2server-resources)

## Prerequisites

You must create the mount directory and give the container full read and write permissions.

## Usage

```
docker run -it --name "esdekal4d2" -v $PWD/content:/home/steam/left4dead2 -p 27035:27035 -p 27035:27035/udp --env SRCDS_PORT=27035 esdeka/gameserverl4d2

testrun:
docker run -it --name "esdekal4d2" -v $PWD/content:/home/steam/left4dead2 -p 27035:27035 -p 27035:27035/udp --env SRCDS_PORT=27035 --rm --env SERVER_NAME="SDK_TEST_SERVER" --env SOURCEMOD_BUILD=6876 --entrypoint /bin/bash esdeka/gameserverl4d2
```

You can also use the Entrypoint and CMD to customize configs and plugins like you would normally with SRCDS (Port must be changed via Env Variable);

```
docker run -it --name "L4D2" 						\
    -v /path/to/local/mount:/home/steam/left4dead2 	\
    -p 27015:27015 									\
    -p 27015:27015/udp 								\
    esdeka/gameserverl4d2            				\
	-insecure                                       \
    +maxplayers ${SRCDS_MAXPLAYERS}                 \
    +sv_pure ${SRCDS_PURE}                          \
    +sv_region ${SRCDS_REGION}                      \
    +sv_lan ${SRCDS_LAN}                            \
    +map ${SRCDS_MAP}                               \
    +ip 0.0.0.0
```

## Environment Variables

* SRCDS_PORT - Port Number for the server to run on (Default 27015)

