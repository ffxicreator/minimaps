local Widescan          = require('shared.widescan')
local map_utils         = require('shared.map_utils')

-- Walk of Echoes [P1] and [P2] - two copies of the same layout.
local ODYSSEY_ZONES     = { [298] = true, [279] = true }

-- Colors {alpha, red, green, blue}
local ENEMY_COLOR       = { 255, 220, 50, 50 }   -- red
local CHEST_COLOR       = { 255, 240, 200, 40 }  -- gold
local PARTY_COLOR       = { 255, 50, 90, 160 }   -- blue
local CONFLUX_COLOR     = { 255, 90, 20, 140 }   -- dark purple, the exit (an Otherworldly Conflux) included
local TRANSLOCATOR_COLOR = { 255, 255, 255, 255 } -- white

-- Fixed on the map already, so left out of the widescan dots.
local FIXTURES          = { 'conflux', 'translocator', 'vortex', 'junction' }

-- The wiki's 512x512 map images cropped to their middle 256x256 (left=128, top=128), which holds every floor
-- plan. Every floor is fitted to waypoints recorded along its walls (fit_maps.py next to the original maps): the
-- scale that keeps each Sheol's waypoints inside its walls, then each floor's offset.
local SHEOL_A_SCALE     = 0.5011
local SHEOL_A5_SCALE    = 0.5441 -- floor 5's map is drawn larger than the rest of Sheol A's
local SHEOL_B_SCALE     = 0.5038
local SHEOL_C_SCALE     = 0.494
local MAPS              = {
    shoal_a_f1 = {
        image = 'maps/sheol_a_f1.png', label = 'Sheol A - Floor 1',
        ref_world = { x = 160, y = 220 }, ref_pixel = { x = 88.05, y = 138.25 }, x_scale = SHEOL_A_SCALE, y_scale = SHEOL_A_SCALE,
    },
    shoal_a_f2 = {
        image = 'maps/sheol_a_f2.png', label = 'Sheol A - Floor 2',
        ref_world = { x = -80, y = -660 }, ref_pixel = { x = 185.56, y = 175.91 }, x_scale = SHEOL_A_SCALE, y_scale = SHEOL_A_SCALE,
    },
    shoal_a_f3 = {
        image = 'maps/sheol_a_f3.png', label = 'Sheol A - Floor 3',
        ref_world = { x = 336, y = -600 }, ref_pixel = { x = 159.59, y = 130.91 }, x_scale = SHEOL_A_SCALE, y_scale = SHEOL_A_SCALE,
    },
    shoal_a_f4 = {
        image = 'maps/sheol_a_f4.png', label = 'Sheol A - Floor 4',
        ref_world = { x = -140, y = -280 }, ref_pixel = { x = 126.4, y = 145.1 }, x_scale = SHEOL_A_SCALE, y_scale = SHEOL_A_SCALE,
    },
    shoal_a_f5 = {
        image = 'maps/sheol_a_f5.png', label = 'Sheol A - Floor 5',
        ref_world = { x = -480, y = -20 }, ref_pixel = { x = 95.69, y = 81.9 }, x_scale = SHEOL_A5_SCALE, y_scale = SHEOL_A5_SCALE,
    },
    shoal_a_f6 = {
        image = 'maps/sheol_a_f6.png', label = 'Sheol A - Floor 6',
        ref_world = { x = -640, y = 620 }, ref_pixel = { x = 86.04, y = 132.3 }, x_scale = SHEOL_A_SCALE, y_scale = SHEOL_A_SCALE,
    },
    shoal_a_f7 = {
        image = 'maps/sheol_a_f7.png', label = 'Sheol A - Floor 7',
        ref_world = { x = -320, y = 580 }, ref_pixel = { x = 85.69, y = 147 }, x_scale = SHEOL_A_SCALE, y_scale = SHEOL_A_SCALE,
    },
    sheol_b_f1 = {
        image = 'maps/sheol_b_f1.png', label = 'Sheol B - Floor 1',
        ref_world = { x = 700, y = -640 }, ref_pixel = { x = 135.38, y = 101.02 }, x_scale = SHEOL_B_SCALE, y_scale = SHEOL_B_SCALE,
    },
    sheol_b_f2 = {
        image = 'maps/sheol_b_f2.png', label = 'Sheol B - Floor 2',
        ref_world = { x = -700, y = -760 }, ref_pixel = { x = 65.74, y = 165.27 }, x_scale = SHEOL_B_SCALE, y_scale = SHEOL_B_SCALE,
    },
    sheol_b_f3 = {
        image = 'maps/sheol_b_f3.png', label = 'Sheol B - Floor 3',
        ref_world = { x = 180, y = 640 }, ref_pixel = { x = 69.77, y = 116.17 }, x_scale = SHEOL_B_SCALE, y_scale = SHEOL_B_SCALE,
    },
    sheol_b_f4 = {
        image = 'maps/sheol_b_f4.png', label = 'Sheol B - Floor 4',
        ref_world = { x = 520, y = 700 }, ref_pixel = { x = 67.41, y = 92.37 }, x_scale = SHEOL_B_SCALE, y_scale = SHEOL_B_SCALE,
    },
    sheol_b_f5 = {
        image = 'maps/sheol_b_f5.png', label = 'Sheol B - Floor 5',
        ref_world = { x = 280, y = -100 }, ref_pixel = { x = 139.97, y = 58.39 }, x_scale = SHEOL_B_SCALE, y_scale = SHEOL_B_SCALE,
    },
    sheol_b_f6 = {
        image = 'maps/sheol_b_f6.png', label = 'Sheol B - Floor 6',
        ref_world = { x = -500, y = 200 }, ref_pixel = { x = 202.25, y = 153.25 }, x_scale = SHEOL_B_SCALE, y_scale = SHEOL_B_SCALE,
    },
    sheol_c_f1 = {
        image = 'maps/sheol_c_f1.png', label = 'Sheol C - Floor 1',
        ref_world = { x = 632, y = 340 }, ref_pixel = { x = 144.54, y = 75.05 }, x_scale = SHEOL_C_SCALE, y_scale = SHEOL_C_SCALE,
    },
    sheol_c_f2 = {
        image = 'maps/sheol_c_f2.png', label = 'Sheol C - Floor 2',
        ref_world = { x = -752, y = -420 }, ref_pixel = { x = 101.3, y = 130.25 }, x_scale = SHEOL_C_SCALE, y_scale = SHEOL_C_SCALE,
    },
    sheol_c_f3 = {
        image = 'maps/sheol_c_f3.png', label = 'Sheol C - Floor 3',
        ref_world = { x = 648, y = -140 }, ref_pixel = { x = 118.1, y = 114.78 }, x_scale = SHEOL_C_SCALE, y_scale = SHEOL_C_SCALE,
    },
    sheol_c_f4 = {
        image = 'maps/sheol_c_f4.png', label = 'Sheol C - Floor 4',
        ref_world = { x = -352, y = 180 }, ref_pixel = { x = 82.18, y = 160.78 }, x_scale = SHEOL_C_SCALE, y_scale = SHEOL_C_SCALE,
    },
}

-- Recorded positions, per floor.
local CONFLUXES         = {
    shoal_a_f1 = { { x = 160, y = 220 } },
    shoal_a_f2 = { { x = -80, y = -660 }, { x = -220, y = -440 } },
    shoal_a_f3 = { { x = 260, y = -680 }, { x = 380, y = -600 } },
    shoal_a_f4 = { { x = -140, y = -280 }, { x = -40, y = -300 } },
    shoal_a_f5 = { { x = -480, y = -20 }, { x = -360, y = -20 } },
    shoal_a_f6 = { { x = -640, y = 620 }, { x = -520, y = 700 } },
    shoal_a_f7 = { { x = -320, y = 580 } },
    sheol_b_f1 = { { x = 700, y = -640 } },
    sheol_b_f2 = { { x = -700, y = -760 }, { x = -620, y = -640 } },
    sheol_b_f3 = { { x = 180, y = 640 }, { x = 400, y = 740 } },
    sheol_b_f4 = { { x = 520, y = 700 }, { x = 760, y = 540 } },
    sheol_b_f5 = { { x = 280, y = -100 }, { x = 140, y = -280 } },
    sheol_b_f6 = { { x = -500, y = 200 } },
    sheol_c_f1 = { { x = 632, y = 340 } },
    sheol_c_f2 = { { x = -752, y = -420 }, { x = -648, y = -420 } },
    sheol_c_f3 = { { x = 648, y = -140 }, { x = 672, y = -260 } },
    sheol_c_f4 = { { x = -352, y = 180 } },
}
local TRANSLOCATORS     = {
    shoal_a_f1 = { { x = 160, y = 160 } },
    shoal_a_f3 = { { x = 336, y = -600 } },
    shoal_a_f5 = { { x = -420, y = -222 } },
    sheol_b_f1 = { { x = 680, y = -792 } },
    sheol_b_f3 = { { x = 208, y = 560 } },
    sheol_b_f6 = { { x = -548, y = 320 } },
    sheol_c_f1 = { { x = 524, y = 236 } },
    sheol_c_f2 = { { x = -700, y = -336 } },
}
local EXITS             = {
    shoal_a_f7 = { { x = -100, y = 600 } },
    sheol_b_f5 = { { x = 358, y = -340 } },
    sheol_c_f4 = { { x = -180, y = 192 } },
}

-- Landmarks for working out which floor we're on (area ids from the route builder's data - Sheol A's are
-- spelled 'shoal').
local AREAS             = {
    proximity_threshold = 300,
    areas = {
        -- Lilith's HTMB battlefield shares the zone; with no map, the minimap stays hidden there.
        lilith_battlefield = {
            landmarks = {
                { x = -700, y = -175 },
                { x = -695.1, y = -132.5 },
            },
        },
        sheol_b_f1 = {
            landmarks = {
                { x = 674.7, y = -800.74 },
                { x = 609.21, y = -570.04 },
            },
        },
        sheol_b_f2 = {
            landmarks = {
                { x = -699.59, y = -754.94 },
            },
        },
        sheol_b_f3 = {
            landmarks = {
                { x = 179.97, y = 645.18 },
                { x = 377.04, y = 739.57 },
            },
        },
        sheol_b_f4 = {
            landmarks = {
                { x = 521.93, y = 699.93 },
                { x = 740.13, y = 701.07 },
            },
        },
        sheol_b_f5 = {
            landmarks = {
                { x = 284, y = -100 },
                { x = 305.79, y = -298.64 },
            },
        },
        sheol_b_f6 = {
            landmarks = {
                { x = -499.73, y = 202.83 },
            },
        },
        sheol_c_f1 = {
            landmarks = {
                { x = 490.19, y = 260.6 },
                { x = 712.15, y = 226.58 },
            },
        },
        sheol_c_f2 = {
            landmarks = {
                { x = -750, y = -420 },
            },
        },
        sheol_c_f3 = {
            landmarks = {
                { x = 650, y = -140 },
                { x = 579.44, y = -350.77 },
                { x = 670, y = -260 },
            },
        },
        sheol_c_f4 = {
            landmarks = {
                { x = -350.24, y = 179.52 },
                { x = -177.14, y = 181.64 },
            },
        },
        shoal_a_f1 = {
            landmarks = {
                { x = 140, y = 138 },
            },
        },
        shoal_a_f2 = {
            landmarks = {
                { x = -91.45, y = -659.62 },
                { x = -291.36, y = -578.39 },
            },
        },
        shoal_a_f3 = {
            landmarks = {
                { x = 330.25, y = -600.81 },
            },
        },
        shoal_a_f4 = {
            landmarks = {
                { x = -140.06, y = -271.52 },
            },
        },
        shoal_a_f5 = {
            landmarks = {
                { x = -474, y = -20 },
                { x = -387.71, y = -23.06 },
            },
        },
        shoal_a_f6 = {
            landmarks = {
                { x = -517.88, y = 530.04 },
            },
        },
        shoal_a_f7 = {
            landmarks = {
                { x = -307.8, y = 580 },
                { x = -100.78, y = 592.91 },
            },
        },
        shoal_lobby = {
            landmarks = {
                { x = 20.87, y = 17.28 },
            },
        },
    },
}

---@return table<string, boolean>
local function party_names()
    local names = {}
    local party = windower.ffxi.get_party()
    for i = 0, 5 do
        local member = party['p' .. i]
        if member and member.name then names[member.name:lower()] = true end
    end
    return names
end

---@param name string
---@return string|nil category
local function classify(name)
    local lowered = name:lower()
    for _, fixture in ipairs(FIXTURES) do
        if lowered:find(fixture, 1, true) then return nil end
    end
    if party_names()[lowered] then return nil end
    return 'enemies'
end

---Chests are NPCs, which widescan doesn't report - read the ones in memory range instead. Opened ones
---stop being targetable, so they drop off.
---@return table[]
local function chests_in_memory()
    local chests = {}
    for _, mob in pairs(windower.ffxi.get_mob_array()) do
        if mob.valid_target and mob.name == 'Chest' then table.insert(chests, mob) end
    end
    return chests
end

---@type MinimapDefinition
return {
    key         = 'odyssey',
    label       = 'Odyssey',
    zones       = ODYSSEY_ZONES,
    asset_dir   = windower.addon_path .. 'odyssey/',
    native_size = 256,
    base_size   = 350,
    areas       = AREAS,
    maps        = MAPS,
    scanner     = Widescan.new('Odyssey', classify, 5),
    layers      = function(player, scan, map_id)
        return {
            { name = 'conflux',      kind = 'points', color = CONFLUX_COLOR,      size = 5, items = CONFLUXES[map_id] or {} },
            { name = 'translocator', kind = 'points', color = TRANSLOCATOR_COLOR, size = 5, items = TRANSLOCATORS[map_id] or {} },
            { name = 'exit',         kind = 'points', color = CONFLUX_COLOR,      size = 5, items = EXITS[map_id] or {} },
            { name = 'enemy',        kind = 'scan',   color = ENEMY_COLOR,        size = 3, items = scan:get('enemies') },
            { name = 'chest',        kind = 'live',   color = CHEST_COLOR,        size = 4, items = chests_in_memory() },
            { name = 'party',        kind = 'live',   color = PARTY_COLOR,        size = 3, items = map_utils.get_party_members() },
        }
    end,
}
