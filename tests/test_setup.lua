-- Stands in for Windower so the addon's modules load under busted. Run specs from the addon root:
--   busted tests
package.path = './?.lua;' .. package.path

windower = {
    addon_path = './',
    add_to_chat = function() end,
    register_event = function() return 1 end,
    unregister_event = function() end,
    ffxi = {
        get_info = function() return { zone = 0, logged_in = true } end,
        get_mob_by_target = function() return nil end,
        get_mob_by_index = function() return nil end,
        get_mob_array = function() return {} end,
        get_party = function() return {} end,
    },
    prim = {
        create = function() end,
        delete = function() end,
        set_size = function() end,
        set_color = function() end,
        set_position = function() end,
        set_visibility = function() end,
    },
}

package.preload['socket'] = function() return { gettime = os.time } end
package.preload['packets'] = function()
    return { new = function() return {} end, inject = function() end, parse = function() return {} end }
end
package.preload['images'] = function() return { new = function() error('stub images.new in the spec') end } end
package.preload['texts'] = function() return { new = function() error('stub texts.new in the spec') end } end
