fx_version 'bodacious'
game 'gta5'
author 'Lixeiro Charmoso#1104'

ui_page "nui/ui.html"

lua54 'yes'

escrow_ignore {
	'config.lua',
	'client.lua',
	'server_utils.lua',
	'lang/*.lua',
}

client_scripts {
	"client.lua",
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"server_utils.lua",
	"server.lua",
}

shared_scripts {
	'@PolyZone/client.lua',
	"lang/*.lua",
	"config.lua",
	"fishing/fishing_config.lua"
}

files {
	"nui/lang/*",
	"nui/ui.html",
	"nui/panel.js",
	"nui/css/*",
	"nui/images/*",
	"nui/images/**",
}