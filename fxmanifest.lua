fx_version 'cerulean'
game 'gta5'

author 'Elio'
description '/me command but it\'s 3D printed'
version '3.0'

shared_script 'config.lua'
client_script 'client.lua'
server_scripts {
    '@hrp-metrics/lib/log.lua', -- HrpLog: structured logs (PRODUCTION-SERVER docs/dev/logs.md)
    'server.lua',
}
