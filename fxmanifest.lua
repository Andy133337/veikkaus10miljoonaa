fx_version 'cerulean'
game 'gta5'

description 'QB-ScratchCard - Neo-Ässä Raaputusarpa'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@qb-core/shared/items.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/shop.html',
    'html/shop.css',
    'html/shop.js'
}