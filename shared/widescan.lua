local packets         = require('packets')
local socket          = require('socket')

local WIDESCAN_PACKET = 0x0F4
local DEATH_EXPIRY    = 20 -- seconds before a dead mob is dropped from the kill list

---@class MinimapScanResult
---@field name string
---@field index number
---@field x number
---@field y number
---@field level number

---Widescans on an interval and sorts each result into a category with `classify(name)`. Results land in
---`self.categories[category][index]`; a nil category means the result isn't shown.
---@class Widescan
---@field label string
---@field classify fun(name: string): string|nil
---@field active boolean
---@field interval number
---@field next_scan_at number
---@field categories table<string, table<number, MinimapScanResult>>
---@field all_results table<number, MinimapScanResult>
---@field incoming table<number, MinimapScanResult>
---@field kill_list table<number, number>
---@field scan_origin {x: number, y: number}|nil Where we were when our last scan went out
local Widescan        = {}
Widescan.__index      = Widescan

---@param label string Shown in chat output
---@param classify fun(name: string): string|nil
---@param interval number Seconds between scans
---@return Widescan
function Widescan.new(label, classify, interval)
    local self    = setmetatable({}, Widescan)
    self.label    = label
    self.classify = classify
    self.interval = interval
    self.active   = false
    self:reset()
    return self
end

function Widescan:reset()
    self.scan_origin  = nil
    self.categories   = {}
    self.all_results  = {}
    self.incoming     = {}
    self.kill_list    = {}
    self.next_scan_at = 0
end

---@param category string
---@return table<number, MinimapScanResult>
function Widescan:get(category)
    return self.categories[category] or {}
end

function Widescan:start()
    self.active = true
    self:reset()
end

function Widescan:stop()
    self.active = false
    self:reset()
end

---@param mob table
---@return boolean
local function is_dead(mob)
    return mob.hpp == 0 or mob.status == 2 or mob.status == 3
end

function Widescan:update_kill_list()
    local now = socket.gettime()
    for index, died_at in pairs(self.kill_list) do
        if now - died_at > DEATH_EXPIRY then self.kill_list[index] = nil end
    end
    for index in pairs(self.all_results) do
        if not self.kill_list[index] then
            local mob = windower.ffxi.get_mob_by_index(index)
            if mob and is_dead(mob) then self.kill_list[index] = now end
        end
    end
end

---Call every frame while the minimap is shown.
function Widescan:update()
    if not self.active then return end
    self:update_kill_list()
    if socket.gettime() < self.next_scan_at then return end

    self.all_results, self.categories = {}, {}
    for index, result in pairs(self.incoming) do
        self.all_results[index] = result
        local category = not self.kill_list[index] and self.classify(result.name)
        if category then
            self.categories[category] = self.categories[category] or {}
            self.categories[category][index] = result
        end
    end

    self.incoming = {}
    local player_mob = windower.ffxi.get_mob_by_target('me')
    self.scan_origin = player_mob and { x = player_mob.x, y = player_mob.y }
    packets.inject(packets.new('outgoing', WIDESCAN_PACKET))
    self.next_scan_at = socket.gettime() + self.interval
end

---Register on 'incoming chunk'.
---@param id number
---@param data string
function Widescan:handle_packet(id, data)
    if id ~= WIDESCAN_PACKET or not self.active then return end
    -- The offsets are from where the server had us at when the scan went out, not where we are by the time
    -- the replies arrive - adding them to our current position drifts the dots by however far we've moved.
    local origin = self.scan_origin or windower.ffxi.get_mob_by_target('me')
    if not origin then return end

    local p = packets.parse('incoming', data)
    self.incoming[p['Index']] = {
        name  = p['Name'],
        index = p['Index'],
        x     = origin.x + p['X Offset'],
        y     = origin.y + p['Y Offset'],
        level = p['Level'],
    }
end

---Prints the last scan's data for one mob.
---@param index number
function Widescan:print_result(index)
    local result = self.all_results[index]
    if not result then
        return windower.add_to_chat(207, ('%s scanner: no scan data for index %d'):format(self.label, index))
    end
    windower.add_to_chat(207, ('%s scanner: [%d] %s  level=%s  x=%.2f y=%.2f'):format(
        self.label, result.index, result.name, tostring(result.level), result.x, result.y))
end

function Widescan:print_results()
    for _, result in pairs(self.all_results) do
        windower.add_to_chat(207, ('%s %s %s (x:%s,y:%s)'):format(
            result.name, result.index, tostring(result.level), result.x, result.y))
    end
end

---@param interval number
function Widescan:set_interval(interval)
    self.interval = interval
    windower.add_to_chat(207, ('%s scanner: interval set to %.1fs'):format(self.label, interval))
end

return Widescan
