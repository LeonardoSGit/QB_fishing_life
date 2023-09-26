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
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	"client.lua",
	"fishing/fishing_client.lua",
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"fishing/fishing_server.lua",
	"server_utils.lua",
	"server.lua"
}

shared_scripts {
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
	"fishing/fishing_panel.js",
	"fishing/fishing_ui.html",
}