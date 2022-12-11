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