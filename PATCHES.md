# Patches

Upstream: https://github.com/eblio/3dme (master)

Fork of 3dme for the core of Heritage-RP/PRODUCTION-SERVER. Every patch is generic: a server sets its own values
through convars or other resources (Heritage-RP/PRODUCTION-SERVER docs/dev/forks.md).

| Patch | Kind | Upstream | Files |
|---|---|---|---|
| `/me` sent only to players in range (`dist`, same routing bucket), cooldown per player, length cap, empty `/me` ignored (PRODUCTION-SERVER#318) | generic | candidate | `server.lua`, `config.lua` |
| Language from ox_lib's replicated locale `ox:locale` (`en` when unset or not in `Languages`) | generic | candidate | `config.lua` |
| Logs and a business record of each `/me` through HrpLog (`@hrp-metrics/lib/log.lua`) | generic | no | `fxmanifest.lua`, `server.lua` |
| Tests: `tests/run.sh` runs `tests/lua/*_spec.lua` in Lua 5.4 through docker (`just test`) | generic | no | `tests/**` |
| Documentation of the fork | generic | no | `README.md`, `PATCHES.md` |
