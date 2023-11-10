fx_version 'cerulean'

game 'gta5'

description 'NewsPaper to show players the news and jail sentences by Destrah'

author 'Destrah'

version '1.0.2'

ui_page 'html/index.html'

server_script {
    '@mysql-async/lib/MySQL.lua',
    'server/svmain.lua'
}

client_scripts {
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

shared_scripts {
	'config.lua',
    '@ox_lib/init.lua',
}

lua54 'yes'