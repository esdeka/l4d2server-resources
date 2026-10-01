# L4D2 Dedicated Server (personal, homeserver)

Left 4 Dead 2 dedicated server with Metamod + SourceMod and a curated plugin set, running in Docker on a Proxmox homeserver.

## Working agreement

- Claude has **read-only** access to the server files (`left4dead2/`, `bin/`). Edits there are made by the user in VS Code. Propose changes as diffs or snippets.
- Other repo files (`.gitignore`, `resources/root/*`, `Dockerfile`) are edited only after the user approves the diff.
- Never commit, push, restart or exec into the container. The user does that.
- **Avoid editing plugin source (`.sp`) and recompiling unless absolutely necessary.** Prefer fixes that leave the plugin binaries untouched:
  1. cvars or config (`cfg/sourcemod/*.cfg`, `data/`, `configs/`), translations, gamedata
  2. moving plugins in or out of `plugins/disabled/`, or swapping in a newer upstream `.smx`
  3. a step in `runServer.sh` that runs on every start (deleting, moving or patching files), even if it repeats every restart
  4. only as a last resort: editing and recompiling a plugin. Explain why the options above don't work first.

## Layout: the repo IS the server install

- `/opt/docker/L4D2` is the full srcds install, bind-mounted into the container as `/home/steam/left4dead2` (`SRCDS_SRV_DIR`).
- Most files are Valve or SourceMod defaults. `.gitignore` ignores everything (`*`) and lists only the custom files (see below).
- GitHub remote: `EsDeKa/l4d2server-resources` (**public**, so never commit secrets: `private.cfg`, rcon passwords, ban lists).

## Docker

- **The live container is started from `/opt/docker/stacks/l4d2/compose.yaml`** (root-owned, hardcoded env), not from `docker-compose.yml` in this repo. The repo copy expects a `.env`, which doesn't exist here.
- Image: `ghcr.io/esdeka/l4d2serverresources:latest`, built from `Dockerfile` by `.github/workflows/docker-publish.yml` on push to `master` when `Dockerfile` or `resources/root/*` change.
- SourceMod and Metamod versions are pinned as ENV in `Dockerfile` (`SOURCEMOD_*`, `METAMOD_*`).
- Port 27025 (`SRCDS_PORT`), `network_mode: host`.

## Start chain

1. `resources/root/start.sh` (entrypoint, runs once per container start): copies the image's `runServer_.sh` to `./runServer.sh`, then loops forever. If a file `./dontrun` exists, the loop drops into bash instead of starting the server.
2. `runServer.sh`, every loop iteration:
   - downloads Metamod/SourceMod if `mm-version`/`sm-version` don't match the pinned ENV
   - on a SourceMod update, `git clone`s this repo and copies it over the install (careful: this overwrites `.git` too)
   - moves `nextmap.smx` to `disabled/`
   - writes `cfg/private_env.cfg` (hostname)
   - runs steamcmd `app_update` for Windows, then Linux (workaround for missing files)
   - runs `workshop.py` to download `$COLLECTIONS` into `addons/workshop/`
   - deletes the bundled `libstdc++`/`libgcc_s` (needed for Accelerator)
   - runs `srcds_run`, passing the image's CMD through `$@`
3. **This is intentional: `./runServer.sh` is a scratch copy for testing.** It is reset from the image only when the container starts (restart, or recreate after an image update). Inside a running container, `quit` re-runs the local `./runServer.sh`, so edits can be tested there without being overwritten.
   - Workflow: edit and test `./runServer.sh` (it's untracked), then copy the change to `resources/root/runServer_.sh` and push so CI rebuilds the image.
   - Before restarting or recreating the container, check that `./runServer.sh` and `resources/root/runServer_.sh` match (`diff runServer.sh resources/root/runServer_.sh`). Any change still only in the local copy is lost.

## `.gitignore` conventions

- One block per plugin: a comment with name, version and date, a source URL, dependencies, then `!/path` lines for each file (`.smx`, `.sp`, gamedata, translations, `cfg/sourcemod/*.cfg`).
- Escape brackets in filenames: `!/left4dead2/addons/sourcemod/plugins/\[pa4H\]ConnectAnnounce.smx`.
- To track a new subdirectory, add it to the "Directory includes" section at the bottom, otherwise git won't look inside it.
- Plugins that can be toggled with the in-game plugin manager live in `plugins/disabled/` and are listed under "DISABLED plugins".
- L4D2 srcds is 32-bit, so `extensions/x64/` binaries are not used.
- Check what's tracked: `git ls-files`. Check why a file is ignored: `git check-ignore -v <path>`.

## Operations

- Console: `docker attach L4D2` (detach with Ctrl-P Ctrl-Q, **not** Ctrl-C). Logs: `docker logs --tail 100 L4D2`.
- Restart without recreating the container: `quit` in the server console. The loop restarts the server and re-runs the updates.
- Maintenance shell: `touch dontrun`, then `quit` in the server console. Remove `dontrun` to resume.
- SourceMod logs: `left4dead2/addons/sourcemod/logs/` (`errors_YYYYMMDD.log`, `L*.log`, `accelerator.log`).
- Loaded MM plugins and extensions: `meta list` / `sm exts list` / `sm plugins list` in the server console.
- Compile a plugin: `cd left4dead2/addons/sourcemod/scripting && ./spcomp <file>.sp -ocompiled/<file>.smx`, then copy the result to `plugins/`.
- Crash dumps: Accelerator writes to `addons/sourcemod/data/dumps/`. Stray `core` files in the repo root can be deleted.

## Manual setup not in git (see README)

`cfg/private.cfg`, `cfg/banned_user.cfg`, `cfg/banned_ip.cfg`, whitelist groups.

## Known issues / TODO

- LMCCore and LMC_SharedCvars were moved to `plugins/disabled/`, so `LMCL4D2CDeathHandler` and `LMCEDeathHandler` fail to load.
- `.gitignore` still lists the old (non-`disabled/`) paths for cannounce, sm_translator, voteblocker and the LMC plugins. It also has stale entries: `LMC_L4D2_Menu_Choosing`, `x64/rip.ext.so`, `cfg/sourcemod/configs`.
- The lib removal is tested in `./runServer.sh` and copied to `resources/root/runServer_.sh`, but not committed and pushed yet. The image doesn't have it until then.
- `runServer_.sh`: guard the resources clone so it skips when `.git` exists, and use `rm -f` for the library removal.
- The `srcds_run -steamcmd_script` flag has no effect without `-autoupdate`.
- Two compose files exist (repo copy and stacks copy). Pick one.
