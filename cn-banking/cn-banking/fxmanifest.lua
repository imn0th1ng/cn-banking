fx_version 'bodacious'
games { 'rdr3', 'gta5' }

client_scripts {
	'@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
	'client/cl_*.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/sv_*.lua',
}

ui_page 'html/bank.html'

files {
    'html/bank.html',
    'html/style.css',
    'html/load.css',
    'html/ui.js',
    'html/img/*.png',
}