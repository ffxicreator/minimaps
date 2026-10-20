---@diagnostic disable: duplicate-set-field, missing-fields, need-check-nil
require('tests.test_setup')

local function fake_drawable()
    local drawable = { x = 100, y = 200, shown = false }
    function drawable:pos(x, y)
        if x then self.x, self.y = x, y end
        return self.x, self.y
    end
    function drawable:path(path) self.image = path end
    function drawable:text(text) self.label = text end
    function drawable:size() end
    function drawable:extents() return 80, 14 end
    function drawable:show() self.shown = true end
    function drawable:hide() self.shown = false end
    function drawable:destroy() end
    return drawable
end
package.loaded['images'] = { new = function() return fake_drawable() end }
package.loaded['texts'] = { new = function() return fake_drawable() end }

local prims, created_order = {}, {}
windower.prim = {
    create = function(name)
        prims[name] = { visible = false }
        table.insert(created_order, name)
    end,
    delete = function(name) prims[name] = nil end,
    set_size = function(name, width, height) prims[name].width, prims[name].height = width, height end,
    set_color = function() end,
    set_position = function(name, x, y) prims[name].x, prims[name].y = x, y end,
    set_visibility = function(name, visible) if prims[name] then prims[name].visible = visible end end,
}

local area_lookup = require('shared.area_lookup')
local Minimap     = require('shared.minimap')
local nyzul       = require('nyzul_isle.definition')

describe('minimaps', function()
    it('picks the Nyzul map from the nearest landmark, and nothing when too far from any', function()
        assert.equal('nyzul_map_1', area_lookup.area_at({ x = 460, y = -443 }, nyzul.areas))
        assert.equal('nyzul_map_4', area_lookup.area_at({ x = 20, y = -298 }, nyzul.areas))
        assert.is_nil(area_lookup.area_at({ x = 5000, y = 5000 }, nyzul.areas))
    end)

    it("sorts Nyzul's widescan results the way the old scanner did", function()
        local classify = nyzul.scanner.classify
        assert.equal('lamps', classify('RunicLamp'))
        assert.equal('leaders', classify('Long-Gunned Chariot'))
        assert.equal('specified_enemy', classify('Bouncing Ball'))
        assert.equal('specified_enemies', classify('Heraldic Imp'))
        assert.equal('rune_of_transfer', classify('Rune of Transfe'))
        assert.equal('enemies', classify('Imp'))
    end)

    it('knows which Sheol A, B or C floor you are on', function()
        local odyssey = require('odyssey.definition')
        assert.is_true(odyssey.zones[298] and odyssey.zones[279])
        assert.equal('sheol_b_f3', area_lookup.area_at({ x = 208, y = 560 }, odyssey.areas))
        assert.equal('sheol_b_f5', area_lookup.area_at({ x = 358, y = -340 }, odyssey.areas))
        assert.equal('shoal_a_f1', area_lookup.area_at({ x = 160, y = 160 }, odyssey.areas))
        assert.equal('Sheol A - Floor 7', odyssey.maps[area_lookup.area_at({ x = -100, y = 600 }, odyssey.areas)].label)
        assert.equal('Sheol C - Floor 1', odyssey.maps[area_lookup.area_at({ x = 524, y = 236 }, odyssey.areas)].label)
        assert.equal('Sheol C - Floor 4', odyssey.maps[area_lookup.area_at({ x = -180, y = 192 }, odyssey.areas)].label)
        local lilith = area_lookup.area_at({ x = -700, y = -175 }, odyssey.areas)
        assert.equal('lilith_battlefield', lilith)
        assert.is_nil(odyssey.maps[lilith], 'no minimap during the Lilith fight')
    end)

    it("lands every recorded conflux, translocator and exit on its own floor's map", function()
        local odyssey = require('odyssey.definition')
        local map_utils = require('shared.map_utils')
        local floors = 0
        for floor, map in pairs(odyssey.maps) do
            local fixtures = 0
            for _, layer in ipairs(odyssey.layers({}, { get = function() return {} end }, floor)) do
                if layer.kind == 'points' then
                    for _, point in ipairs(layer.items) do
                        local x, y = map_utils.world_to_screen(point.x, point.y, map, { x = 0, y = 0 }, 1, 0, 0, 0)
                        assert.is_true(x > 8 and x < odyssey.native_size - 8 and y > 8 and y < odyssey.native_size - 8,
                            string.format('%s (%d, %d) at (%.1f, %.1f)', floor, point.x, point.y, x, y))
                        fixtures = fixtures + 1
                    end
                end
            end
            assert.is_true(fixtures > 0, floor)
            floors = floors + 1
        end
        assert.equal(17, floors)
    end)

    it('shows Odyssey mobs from widescan, but not the confluxes already on the map', function()
        local classify = require('odyssey.definition').scanner.classify
        local saved_party = windower.ffxi.get_party
        windower.ffxi.get_party = function() return { p0 = { name = 'Desertstorm' }, p1 = { name = 'Koru-Moru' } } end
        local results = {
            classify('Veridical Conflux'), classify('Translocator'), classify('Otherworldly Vortex'),
            classify('Nostos Bat'), classify('Koru-Moru'),
        }
        windower.ffxi.get_party = saved_party
        assert.same({ nil, nil, nil, 'enemies', nil }, results)
    end)

    it('shows the unopened chests in memory, since widescan never reports chests', function()
        local odyssey = require('odyssey.definition')
        local saved_array, saved_party = windower.ffxi.get_mob_array, windower.ffxi.get_party
        local closed = { index = 1, name = 'Chest', valid_target = true, x = 1, y = 2 }
        local opened = { index = 2, name = 'Chest', valid_target = false, x = 3, y = 4 }
        local bat = { index = 3, name = 'Nostos Bat', valid_target = true, x = 5, y = 6 }
        windower.ffxi.get_mob_array = function() return { closed, opened, bat } end
        windower.ffxi.get_party = function() return {} end
        local chest_layer
        for _, layer in ipairs(odyssey.layers({}, { get = function() return {} end }, 'sheol_b_f1')) do
            if layer.name == 'chest' then chest_layer = layer end
        end
        windower.ffxi.get_mob_array, windower.ffxi.get_party = saved_array, saved_party
        assert.equal('live', chest_layer.kind)
        assert.same({ closed }, chest_layer.items)
    end)

    it('places widescan results from where we were when the scan went out, not where we are now', function()
        local packets = require('packets')
        local Widescan = require('shared.widescan')
        local saved = { new = packets.new, inject = packets.inject, parse = packets.parse,
            mob = windower.ffxi.get_mob_by_target, index = windower.ffxi.get_mob_by_index }
        local me = { x = 100, y = 100 }
        packets.new, packets.inject = function() return {} end, function() end
        packets.parse = function() return { Name = 'Nostos Bat', Index = 42, ['X Offset'] = 30, ['Y Offset'] = -20, Level = 1 } end
        windower.ffxi.get_mob_by_target = function() return me end
        windower.ffxi.get_mob_by_index = function() return nil end

        local scan = Widescan.new('Test', function() return 'enemies' end, 5)
        scan:start()
        scan:update()
        me = { x = 160, y = 140 } -- moved before the replies came back
        scan:handle_packet(0x0F4, '')
        scan.next_scan_at = 0
        scan:update()

        packets.new, packets.inject, packets.parse = saved.new, saved.inject, saved.parse
        windower.ffxi.get_mob_by_target, windower.ffxi.get_mob_by_index = saved.mob, saved.index
        local bat = scan:get('enemies')[42]
        assert.same({ 130, 80 }, { bat.x, bat.y })
    end)

    it('shows the map you are on and puts dots where the calibration says', function()
        local saved_mob, saved_party = windower.ffxi.get_mob_by_target, windower.ffxi.get_party
        local player = { x = 460, y = -443, index = 1 }
        windower.ffxi.get_mob_by_target = function() return player end
        windower.ffxi.get_party = function() return { p1 = { mob = { index = 7, x = 470, y = -443 } } } end
        local def = {
            key = 'test', label = 'Test', zones = { [77] = true }, asset_dir = 'assets/',
            native_size = 220, base_size = 220,
            areas = nyzul.areas, maps = nyzul.maps,
            layers = function()
                return { { name = 'party', kind = 'live', color = { 255, 0, 0, 255 }, size = 3,
                    items = { { index = 7, x = 470, y = -443 } } } }
            end,
        }
        local minimap = Minimap.new(def)
        minimap:zone_change(77)
        minimap:update()
        windower.ffxi.get_mob_by_target, windower.ffxi.get_party = saved_mob, saved_party

        assert.equal('assets/maps/4d_1.png', minimap.map_image.image)
        assert.equal('Map 1', minimap.map_label.label)
        assert.same({ 100 + (220 - 80) / 2, 200 + 220 + (35 - 14) / 2 }, { minimap.map_label:pos() })
        local map = nyzul.maps.nyzul_map_1
        local player_dot = prims['test_player_dot']
        assert.is_true(player_dot.visible)
        assert.near(100 + map.ref_pixel.x - 1.5, player_dot.x, 0.001)
        assert.near(200 + map.ref_pixel.y - 1.5, player_dot.y, 0.001)
        local party_dot = prims['test_party_7']
        assert.near(player_dot.x + 10 * map.x_scale, party_dot.x, 0.001)

        assert.equal('test_player_dot', created_order[#created_order], 'the player dot draws over the party dot')
        local function box(name) return { prims[name].x, prims[name].y, prims[name].width, prims[name].height } end
        assert.is_true(prims['test_border_top'].visible)
        assert.same({ 98, 198, 224, 2 }, box('test_border_top'))
        assert.same({ 98, 200 + 220 + 35, 224, 2 }, box('test_border_bottom'))
        assert.same({ 98, 200, 2, 255 }, box('test_border_left'))
        assert.same({ 100 + 220, 200, 2, 255 }, box('test_border_right'))

        minimap:zone_change(1)
        assert.is_nil(prims['test_party_7'])
        assert.is_false(prims['test_player_dot'].visible)
    end)

    it('sends //mm commands to the minimap for the zone you are in', function()
        local minimaps = require('manager')
        local saved_info, saved_chat = windower.ffxi.get_info, windower.add_to_chat
        local said = {}
        windower.add_to_chat = function(_, message) table.insert(said, message) end
        windower.ffxi.get_info = function() return { zone = 279 } end
        minimaps.command('offset', '1', '2')
        windower.ffxi.get_info = function() return { zone = 77 } end
        minimaps.command('offset', '1', '2')
        windower.ffxi.get_info = function() return { zone = 230 } end
        minimaps.command('offset', '1', '2')
        windower.ffxi.get_info, windower.add_to_chat = saved_info, saved_chat
        assert.same({
            'Odyssey minimap: not on a recognised map',
            'Nyzul minimap: not on a recognised map',
            'Minimaps: no minimap for this zone',
        }, said)
    end)
end)
