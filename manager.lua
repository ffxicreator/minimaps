-- Owns one Minimap per content definition (see shared/minimap.lua's MinimapDefinition) and forwards the
-- addon's events to them.
local Minimap  = require('shared.minimap')

local minimaps = {}

---@type Minimap[]
local all      = {
    Minimap.new(require('nyzul_isle.definition')),
    Minimap.new(require('odyssey.definition')),
}

---Call every frame.
function minimaps.update()
    for _, minimap in ipairs(all) do minimap:update() end
end

---@param zone_id number
function minimaps.zone_change(zone_id)
    for _, minimap in ipairs(all) do minimap:zone_change(zone_id) end
end

function minimaps.hide_all()
    for _, minimap in ipairs(all) do minimap:hide() end
end

---On unload: saves each visible map's position, then frees its images, texts and prims.
function minimaps.destroy_all()
    for _, minimap in ipairs(all) do
        minimap:hide()
        minimap:destroy()
    end
end

---Register on 'incoming chunk' - feeds each minimap's widescan.
---@param id number
---@param data string
function minimaps.handle_packet(id, data)
    for _, minimap in ipairs(all) do
        if minimap.def.scanner then minimap.def.scanner:handle_packet(id, data) end
    end
end

---The minimap for the zone we're in, if any.
---@return Minimap|nil
function minimaps.current()
    local info = windower.ffxi.get_info()
    if not info then return nil end
    for _, minimap in ipairs(all) do
        if minimap:covers(info.zone) then return minimap end
    end
end

---e.g. //mm zoom in -> minimaps.command('zoom', 'in'), for the minimap of the current zone.
---@param subcommand string|nil
---@param ... string
function minimaps.command(subcommand, ...)
    local minimap = minimaps.current()
    if not minimap then
        return windower.add_to_chat(207, 'Minimaps: no minimap for this zone')
    end
    if not minimap:command(subcommand, ...) then
        minimap:say('unknown command ' .. tostring(subcommand))
    end
end

return minimaps
