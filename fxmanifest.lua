fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Elysium Development'
description 'Standalone Elevator System for FiveM'
version '1.0.0'

shared_script '@ox_lib/init.lua'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'ox_target',
    'ox_lib'
}
