local images       = require('images')
local texts        = require('texts')
local map_utils    = require('shared.map_utils')
local area_lookup  = require('shared.area_lookup')

local ZOOM_STEP    = 0.25
local ZOOM_MIN     = 0.5
local ZOOM_MAX     = 4.0
local BAR_HEIGHT   = 35
local BORDER       = 2
local PLAYER_SIZE  = 3
local PLAYER_COLOR = { 255, 70, 70, 70 }
local LABEL_STYLE  = {
    font   = 'Arial',
    size   = 10,
    color  = { alpha = 220, red = 220, green = 220, blue = 220 },
    stroke = { width = 2, alpha = 200, red = 0, green = 0, blue = 0 },
}

---@class MinimapMap
---@field image string Path relative to the definition's asset_dir
---@field label string Shown in the info bar
---@field ref_world {x: number, y: number} World position of a known point
---@field ref_pixel {x: number, y: number} That point's pixel in the native-size image
---@field x_scale number Pixels per world unit
---@field y_scale number

---@class MinimapLayer
---@field name string Unique within the definition - part of its prim names
---@field kind 'scan'|'live'|'points' Widescan results, live mobs, or fixed points
---@field color number[] {alpha, red, green, blue}
---@field size number
---@field items table

---@class MinimapDefinition
---@field key string Short name, used in prim names and chat
---@field label string
---@field zones table<number, boolean>
---@field asset_dir string Absolute folder holding the images and the settings file
---@field native_size number Pixel size of the (square) map images
---@field base_size number Displayed size at zoom 1
---@field areas table Landmarks used to pick the current map: {proximity_threshold, areas = {[map_id] = {landmarks}}}
---@field maps table<string, MinimapMap> Keyed by area id
---@field scanner? Widescan
---@field layers fun(player: table, scanner?: Widescan, map_id: string): MinimapLayer[] Drawn in order, under the player

---@class Minimap
---@field def MinimapDefinition
---@field settings_path string
---@field zoom number
---@field visible boolean
---@field current_map_id string|nil
---@field offsets table<string, {x: number, y: number}> Per-map pixel offsets
---@field active table<string, table<any, boolean>> Per-layer prims
---@field player_prim string
---@field bar_prim string
---@field border_prims string[] Top, bottom, left and right edges
---@field map_image table
---@field map_label table
local Minimap      = {}
Minimap.__index    = Minimap

---@param path string
---@return {x: number, y: number, zoom: number}|nil
local function load_settings(path)
    local file = io.open(path, 'r')
    if not file then return nil end
    local content = file:read('*a')
    file:close()
    local x, y, zoom = tonumber(content:match('"x":%s*(-?[%d%.]+)')), tonumber(content:match('"y":%s*(-?[%d%.]+)')),
        tonumber(content:match('"zoom":%s*(-?[%d%.]+)'))
    if not x or not y then return nil end
    return { x = x, y = y, zoom = zoom }
end

---@param path string
---@param x number
---@param y number
---@param zoom number
local function save_settings(path, x, y, zoom)
    local file = io.open(path, 'w')
    if not file then return end
    file:write(('{"x":%d,"y":%d,"zoom":%s}'):format(x, y, zoom))
    file:close()
end

---@param def MinimapDefinition
---@return Minimap
function Minimap.new(def)
    local self          = setmetatable({}, Minimap)
    self.def            = def
    self.settings_path  = def.asset_dir .. 'minimap_settings.json'
    local settings      = load_settings(self.settings_path) or {}
    self.zoom           = settings.zoom or 1.0
    self.visible        = false
    self.current_map_id = nil
    self.offsets        = {}
    self.active         = {}
    self.player_prim    = def.key .. '_player_dot'
    self.bar_prim       = def.key .. '_info_bar'
    self.border_prims   = {}
    for _, edge in ipairs({ 'top', 'bottom', 'left', 'right' }) do
        table.insert(self.border_prims, def.key .. '_border_' .. edge)
    end

    local start_x       = settings.x or 50
    local start_y       = settings.y or 50
    local display_size  = math.floor(def.base_size * self.zoom)
    -- Four edges rather than one rectangle behind the map, so the map stays see-through.
    for _, edge in ipairs(self.border_prims) do
        windower.prim.create(edge)
        windower.prim.set_color(edge, 255, 0, 0, 0)
        windower.prim.set_visibility(edge, false)
    end

    self.map_image      = images.new({
        texture   = { path = '', fit = false },
        size      = { width = display_size, height = display_size },
        pos       = { x = start_x, y = start_y },
        color     = { alpha = 229, red = 255, green = 255, blue = 255 },
        visible   = false,
        draggable = true,
    })

    windower.prim.create(self.bar_prim)
    windower.prim.set_size(self.bar_prim, display_size, BAR_HEIGHT)
    windower.prim.set_position(self.bar_prim, start_x, start_y + display_size)
    windower.prim.set_color(self.bar_prim, 220, 30, 30, 30)
    windower.prim.set_visibility(self.bar_prim, false)

    self.map_label = texts.new('', {
        text  = LABEL_STYLE,
        pos   = { x = start_x + 4, y = start_y + display_size + 4 },
        bg    = { visible = false },
        flags = { draggable = false },
    })

    map_utils.make_dot(self.player_prim, PLAYER_COLOR, PLAYER_SIZE)
    return self
end

---@return string
function Minimap:prefix(layer_name)
    return self.def.key .. '_' .. layer_name .. '_'
end

---@return number
function Minimap:display_size()
    return math.floor(self.def.base_size * self.zoom)
end

---Floored so the scale matches the rendered pixels exactly.
---@return number
function Minimap:img_scale()
    return self:display_size() / self.def.native_size
end

---@param zone_id number
---@return boolean
function Minimap:covers(zone_id)
    return self.def.zones[zone_id] == true
end

---@param visible boolean
function Minimap:set_border_visible(visible)
    for _, edge in ipairs(self.border_prims) do windower.prim.set_visibility(edge, visible) end
end

---Frames the box at (x, y) of `width` x `height` with BORDER-thick edges just outside it.
---@param x number
---@param y number
---@param width number
---@param height number
function Minimap:place_border(x, y, width, height)
    local boxes = {
        { x - BORDER, y - BORDER, width + 2 * BORDER, BORDER }, -- top
        { x - BORDER, y + height, width + 2 * BORDER, BORDER }, -- bottom
        { x - BORDER, y, BORDER, height },                      -- left
        { x + width, y, BORDER, height },                       -- right
    }
    for i, edge in ipairs(self.border_prims) do
        windower.prim.set_position(edge, boxes[i][1], boxes[i][2])
        windower.prim.set_size(edge, boxes[i][3], boxes[i][4])
    end
end

function Minimap:hide_map_parts()
    self.map_image:hide()
    windower.prim.set_visibility(self.bar_prim, false)
    self:set_border_visible(false)
    self.map_label:hide()
    windower.prim.set_visibility(self.player_prim, false)
    self:clear_layers()
end

function Minimap:update()
    if not self.visible then return end
    local player = windower.ffxi.get_mob_by_target('me')
    if not player then return end

    local map_id = area_lookup.area_at(player, self.def.areas)
    local map = map_id and self.def.maps[map_id]
    if not map then
        self.current_map_id = nil
        return self:hide_map_parts()
    end

    if map_id ~= self.current_map_id then
        self.current_map_id = map_id
        self.map_image:path(self.def.asset_dir .. map.image)
        self.map_label:text(map.label)
        self.map_image:show()
        windower.prim.set_visibility(self.bar_prim, true)
        self:set_border_visible(true)
        self.map_label:show()
    end

    local img_x, img_y = self.map_image:pos()
    local display_size = self:display_size()
    windower.prim.set_position(self.bar_prim, img_x, img_y + display_size)
    windower.prim.set_size(self.bar_prim, display_size, BAR_HEIGHT)
    self:place_border(img_x, img_y, display_size, display_size + BAR_HEIGHT)
    local label_width, label_height = self.map_label:extents()
    self.map_label:pos(img_x + (display_size - label_width) / 2,
        img_y + display_size + (BAR_HEIGHT - label_height) / 2)

    ---@type MinimapView
    local view = {
        map = map,
        offset = self.offsets[map_id] or { x = 0, y = 0 },
        scale = self:img_scale(),
        img_x = img_x,
        img_y = img_y,
        display_size = display_size,
    }

    if self.def.scanner then self.def.scanner:update() end
    local any_created = false
    for _, layer in ipairs(self.def.layers(player, self.def.scanner, map_id)) do
        local prefix, active = self:prefix(layer.name), self.active[layer.name] or {}
        local update = layer.kind == 'scan' and map_utils.update_ws_pool
            or layer.kind == 'live' and map_utils.update_live_pool
            or map_utils.update_point_pool
        local created
        self.active[layer.name], created = update(prefix, layer, layer.items, active, view)
        any_created = any_created or created
    end
    -- Prims draw in creation order, so remake the player dot after any new ones to keep it on top.
    if any_created then
        windower.prim.delete(self.player_prim)
        map_utils.make_dot(self.player_prim, PLAYER_COLOR, PLAYER_SIZE)
    end

    local sx, sy = map_utils.world_to_screen(player.x, player.y, map, view.offset, view.scale, img_x, img_y,
        PLAYER_SIZE)
    windower.prim.set_position(self.player_prim, sx, sy)
    windower.prim.set_visibility(self.player_prim, true)
end

function Minimap:clear_layers()
    for name, active in pairs(self.active) do
        map_utils.clear_pool(self:prefix(name), active)
    end
    self.active = {}
end

function Minimap:show()
    self.visible = true
    self.current_map_id = nil
    if self.def.scanner then self.def.scanner:start() end
end

function Minimap:hide()
    if self.visible then
        local x, y = self.map_image:pos()
        save_settings(self.settings_path, x, y, self.zoom)
    end
    self.visible = false
    self.current_map_id = nil
    if self.def.scanner then self.def.scanner:stop() end
    self:hide_map_parts()
end

---@param zone_id number
function Minimap:zone_change(zone_id)
    if self:covers(zone_id) then
        self:show()
    else
        self:hide()
    end
end

---@param message string
function Minimap:say(message)
    windower.add_to_chat(207, self.def.label .. ' minimap: ' .. message)
end

---@param level number
function Minimap:set_zoom(level)
    self.zoom = math.max(ZOOM_MIN, math.min(ZOOM_MAX, level))
    local display_size = self:display_size()
    self.map_image:size(display_size, display_size)
    local x, y = self.map_image:pos()
    save_settings(self.settings_path, x, y, self.zoom)
    self:say(('zoom %.2fx (%dpx)'):format(self.zoom, display_size))
end

---@param direction number 1 or -1
function Minimap:step_zoom(direction)
    self:set_zoom(self.zoom + direction * ZOOM_STEP)
end

---@param sx number
---@param sy? number
function Minimap:set_scale(sx, sy)
    for _, map in pairs(self.def.maps) do
        map.x_scale = sx
        map.y_scale = sy or sx
    end
    self:say(('scale set to x=%.3f y=%.3f'):format(sx, sy or sx))
end

---@param ox number
---@param oy number
function Minimap:set_offset(ox, oy)
    if not self.current_map_id then return self:say('not on a recognised map') end
    self.offsets[self.current_map_id] = { x = ox, y = oy }
    self:say(('offset for %s set to (%d, %d)'):format(self.current_map_id, ox, oy))
end

function Minimap:print_offsets()
    self:say('offsets:')
    for map_id, offset in pairs(self.offsets) do
        windower.add_to_chat(207, ('  %s: (%d, %d)'):format(map_id, offset.x, offset.y))
    end
end

---Handles the shared subcommands; returns false for ones it doesn't know.
---@param command string|nil
---@param arg1 string|nil
---@param arg2 string|nil
---@return boolean handled
function Minimap:command(command, arg1, arg2)
    if command == nil or command == 'show' then
        self:show()
    elseif command == 'hide' then
        self:hide()
    elseif command == 'offset' then
        self:set_offset(tonumber(arg1) or 0, tonumber(arg2) or 0)
    elseif command == 'offsets' then
        self:print_offsets()
    elseif command == 'scale' then
        local sx = tonumber(arg1)
        if not sx then return self:say('usage: scale <x> [y]') or true end
        self:set_scale(sx, tonumber(arg2))
    elseif command == 'zoom' then
        if arg1 == 'in' or arg1 == 'out' then
            self:step_zoom(arg1 == 'in' and 1 or -1)
        elseif tonumber(arg1) then
            self:set_zoom(tonumber(arg1) --[[@as number]])
        else
            self:say('usage: zoom <value> | in | out')
        end
    elseif self.def.scanner and command == 'info' then
        local target = windower.ffxi.get_mob_by_target('t')
        if not target then return self:say('no target') or true end
        self.def.scanner:print_result(target.index)
    elseif self.def.scanner and command == 'print' then
        self.def.scanner:print_results()
    elseif self.def.scanner and command == 'scan_interval' then
        local interval = tonumber(arg1)
        if not interval then return self:say('usage: scan_interval <seconds>') or true end
        self.def.scanner:set_interval(interval)
    else
        return false
    end
    return true
end

function Minimap:destroy()
    self:clear_layers()
    self.map_image:destroy()
    self.map_label:destroy()
    windower.prim.delete(self.bar_prim)
    for _, edge in ipairs(self.border_prims) do windower.prim.delete(edge) end
    windower.prim.delete(self.player_prim)
end

return Minimap
