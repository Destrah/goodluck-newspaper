fx_version 'cerulean'

game 'gta5'

description 'NewsPaper to show players the news and jail sentences by Destrah'

author 'Destrah'

version '1.0.2'

ui_page 'html/index.html'

server_script {
    '@mysql-async/lib/MySQL.lua',
--    '@es_extended/locale.lua', -- Comment in if using ESX
    'config.lua',
    'server/svmain.lua'
}

client_scripts {
--	'@es_extended/locale.lua', -- Comment in if using ESX
    'config.lua',
    'client/main.lua'
} 

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/listener.js',
    'html/newspaper.png',
    'html/mugshot.jpg'
}

lua54 'yes'