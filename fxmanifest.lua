fx_version 'cerulean'
game 'gta5'
name 'Giveaway'
description 'Giveaway System'
author 'Frontend and Backend by sysaqua'
version '1.0.0'
lua54 'yes'
is_cfxv2 'yes'
use_experimental_fxv2_oal 'yes'

client_scripts {
    '@es_extended/imports.lua',
    'backend/config/config.lua',
    'backend/client/main.lua',
}

server_scripts {
    '@es_extended/imports.lua',
    'backend/config/config.lua',
    'backend/server/main.lua',
}

ui_page 'frontend/index.html'
files {
    'frontend/index.html',
    'frontend/**/*',
}