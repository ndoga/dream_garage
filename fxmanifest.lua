fx_version "adamant"
game 'gta5'
name "dream_garage"
lua54 "yes"
shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/**.**"
}
client_scripts {
    "client/**.**"
}