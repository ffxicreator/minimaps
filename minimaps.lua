_addon.name     = 'Minimaps'
_addon.author   = 'Desertstorm'
_addon.version  = '1.0.0'
_addon.commands = { 'minimaps', 'mm' }

local socket          = require('socket')
local minimaps        = require('manager')

local UPDATE_INTERVAL = 0.05
local next_update     = 0

local function show_for_current_zone()
    local info = windower.ffxi.get_info()
    if info and info.logged_in then minimaps.zone_change(info.zone) end
end

local function help()
    for _, line in ipairs({
        'Minimaps - commands act on the minimap for the zone you are in:',
        '  //mm show | hide',
        '  //mm zoom in | out | <value>',
        '  //mm offset <x> <y>   - nudge this map by image pixels (not saved) really only used for debugging',
        '  //mm offsets          - list the offsets set this session (debugging)',
        '  //mm scale <x> [y]    - try a scale for every map of this content (debugging)',
        '  //mm info             - widescan data for your target',
        '  //mm print            - every result of the last widescan',
        '  //mm scan_interval <s> changes how often a scan goes out.',
    }) do
        windower.add_to_chat(207, line)
    end
end

windower.register_event('load', show_for_current_zone)
windower.register_event('login', show_for_current_zone)
windower.register_event('zone change', function(new_id) minimaps.zone_change(new_id) end)
windower.register_event('logout', minimaps.hide_all)
windower.register_event('unload', minimaps.destroy_all)
windower.register_event('incoming chunk', minimaps.handle_packet)

windower.register_event('prerender', function()
    local now = socket.gettime()
    if now < next_update then return end
    next_update = now + UPDATE_INTERVAL
    minimaps.update()
end)

windower.register_event('addon command', function(command, ...)
    if command == nil or command == 'help' then return help() end
    minimaps.command(command, ...)
end)
