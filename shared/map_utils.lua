local MapUtils = {}

---@param name string
---@param color number[] {alpha, red, green, blue}
---@param size number
function MapUtils.make_dot(name, color, size)
    windower.prim.create(name)
    windower.prim.set_size(name, size, size)
    windower.prim.set_color(name, color[1], color[2], color[3], color[4])
    windower.prim.set_visibility(name, false)
end

---@param a {x: number, y: number}
---@param b {x: number, y: number}
---@return number
function MapUtils.distance(a, b)
    return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end

---@return table[] mobs of the other party members in range
function MapUtils.get_party_members()
    local members = {}
    local party = windower.ffxi.get_party()
    for i = 1, 5 do
        local member = party['p' .. i]
        if member and member.mob then
            members[#members + 1] = member.mob
        end
    end
    return members
end

---Maps a world (x, y) onto the top-left screen corner of a dot of `dot_size`.
---@param world_x number
---@param world_y number
---@param map table ref_world, ref_pixel, x_scale, y_scale
---@param offset {x: number, y: number}
---@param img_scale number
---@param img_x number
---@param img_y number
---@param dot_size number
---@return number, number
function MapUtils.world_to_screen(world_x, world_y, map, offset, img_scale, img_x, img_y, dot_size)
    local px = map.ref_pixel.x + (world_x - map.ref_world.x) * map.x_scale + offset.x
    local py = map.ref_pixel.y - (world_y - map.ref_world.y) * map.y_scale + offset.y
    return img_x + px * img_scale - dot_size / 2,
        img_y + py * img_scale - dot_size / 2
end

---@param sx number
---@param sy number
---@param img_x number
---@param img_y number
---@param display_size number
---@param dot_size number
---@return boolean
function MapUtils.in_map_bounds(sx, sy, img_x, img_y, display_size, dot_size)
    local cx = sx + dot_size / 2
    local cy = sy + dot_size / 2
    return cx >= img_x and cx <= img_x + display_size
        and cy >= img_y and cy <= img_y + display_size
end

---@class MinimapView
---@field map table
---@field offset {x: number, y: number}
---@field scale number
---@field img_x number
---@field img_y number
---@field display_size number

---Places a pool of dots, one per item keyed by `key_of(item)`. Creates prims for new items and deletes
---them for items that are gone.
---@param prefix string
---@param layer {color: number[], size: number}
---@param items table
---@param key_of fun(item: table): any
---@param position_of fun(item: table): number, number
---@param active table<any, boolean>
---@param view MinimapView
---@return table<any, boolean> new_active
---@return boolean created Whether any new prims were made - they draw over older ones
local function update_pool(prefix, layer, items, key_of, position_of, active, view)
    local new_active, created = {}, false
    for _, item in pairs(items) do
        local key = key_of(item)
        local prim_name = prefix .. key
        if not active[key] then
            windower.prim.create(prim_name)
            windower.prim.set_size(prim_name, layer.size, layer.size)
            windower.prim.set_color(prim_name, layer.color[1], layer.color[2], layer.color[3], layer.color[4])
            created = true
        end
        new_active[key] = true

        local x, y = position_of(item)
        local sx, sy = MapUtils.world_to_screen(x, y, view.map, view.offset, view.scale, view.img_x, view.img_y,
            layer.size)
        local visible = MapUtils.in_map_bounds(sx, sy, view.img_x, view.img_y, view.display_size, layer.size)
        if visible then windower.prim.set_position(prim_name, sx, sy) end
        windower.prim.set_visibility(prim_name, visible)
    end

    for key in pairs(active) do
        if not new_active[key] then windower.prim.delete(prefix .. key) end
    end
    return new_active, created
end

---Dots for widescan results (keyed by mob index), using the live position when the mob is in memory range.
---@param prefix string
---@param layer {color: number[], size: number, snap?: number}
---@param results table<number, {index: number, x: number, y: number}>
---@param active table<number, boolean>
---@param view MinimapView
---@return table<number, boolean>
---@return boolean created
function MapUtils.update_ws_pool(prefix, layer, results, active, view)
    local snap = layer.snap or 0.5
    return update_pool(prefix, layer, results,
        function(result) return result.index end,
        function(result)
            local live = windower.ffxi.get_mob_by_index(result.index)
            if not live then return result.x, result.y end
            return math.floor(live.x / snap + 0.5) * snap, math.floor(live.y / snap + 0.5) * snap
        end,
        active, view)
end

---Dots for live mobs, keyed by mob index.
---@param prefix string
---@param layer {color: number[], size: number}
---@param mobs table[]
---@param active table<number, boolean>
---@param view MinimapView
---@return table<number, boolean>
---@return boolean created
function MapUtils.update_live_pool(prefix, layer, mobs, active, view)
    return update_pool(prefix, layer, mobs,
        function(mob) return mob.index end,
        function(mob) return mob.x, mob.y end,
        active, view)
end

---Dots for fixed points (e.g. confluxes), keyed by their position in the list.
---@param prefix string
---@param layer {color: number[], size: number}
---@param points {x: number, y: number}[]
---@param active table<number, boolean>
---@param view MinimapView
---@return table<number, boolean>
---@return boolean created
function MapUtils.update_point_pool(prefix, layer, points, active, view)
    local keyed = {}
    for i, point in ipairs(points) do keyed[i] = { key = i, x = point.x, y = point.y } end
    return update_pool(prefix, layer, keyed,
        function(point) return point.key end,
        function(point) return point.x, point.y end,
        active, view)
end

---@param prefix string
---@param active table<any, boolean>
---@return table
function MapUtils.clear_pool(prefix, active)
    for key in pairs(active) do windower.prim.delete(prefix .. key) end
    return {}
end

return MapUtils
