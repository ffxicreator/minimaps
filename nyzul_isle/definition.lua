local Widescan          = require('shared.widescan')
local map_utils         = require('shared.map_utils')

local NYZUL_ZONE        = 77

local ENEMY_LEADERS     = {
    -- Chariots
    ['long-gunned chariot']   = true,
    ['long-gunnedcha']        = true,
    ['long-horned chariot']   = true,
    ['long-hornedcha']        = true,
    ['battledressed chariot'] = true,
    ['battledressed cha']     = true,
    ['shielded chariot']      = true,
    ['shieldedchario']        = true,
    ['racingchariot']         = true,
    -- Flans
    ['anisecustard']          = true,
    ['carawaycustard']        = true,
    ['cinnamoncustard']       = true,
    ['cinnamoncustar']        = true,
    ['cumincustard']          = true,
    ['gingercustard']         = true,
    ['nutmegcustard']         = true,
    ['mintcustard']           = true,
    ['vanillacustard']        = true,
    -- Imps
    ['mokka']                 = true,
    ['mokke']                 = true,
    ['mokku']                 = true,
    -- Poroggos
    ['eririsamariri']         = true,
    ['oririsamariri']         = true,
    ['uririsamariri']         = true,
    -- Soulflayers
    ['vileineef']             = true,
    ['vilewahdaha']           = true,
    ['vileyabeewa']           = true,
    -- Qiqirns
    ['gemheisterroo']         = true,
    ['quick draw sasaroon']   = true,
    ['quickdrawsasa']         = true,
    ['stealthbomberg']        = true,
    ['qiqirntreasure']        = true,
    ['qiqirn archaeologist']  = true,
    ['qiqirnarchaeol']        = true,
    -- HNMs (floors 20/40)
    ['adamantoise']           = true,
    ['behemoth']              = true,
    ['fafnir']                = true,
    -- HNMs (floors 60/80/100)
    ['cerberus']              = true,
    ['hydra']                 = true,
    ['khimaira']              = true,
}

-- "Eliminate specified enemy" objective: single mob that checks as ITG.
local SPECIFIED_ENEMY   = {
    ['ziz']            = true,
    ['bouncingball']   = true,
    ['ominousweapon']  = true,
    ['tomtittat']      = true,
    ["friar'slantern"] = true,
    ['deathcap']       = true,
    ['wildkarakul']    = true,
    ['thousandeyes']   = true,
    ['leshy']          = true,
}

-- "Eliminate specified enemies" objective: a whole family that checks as ITG.
local SPECIFIED_ENEMIES = {
    ['heraldicimp']  = true,
    ['poroggogent']  = true,
    ['psycheflayer'] = true,
    ['ebonypudding'] = true,
}

local LAMP_NAME         = 'runiclamp'
local RUNE_OF_TRANSFER  = 'rune of transfer'

-- Colors {alpha, red, green, blue}
local LAMP_COLOR        = { 255, 50, 150, 100 } -- green
local SPEC_ENEMIES_COLOR = { 255, 50, 220, 220 } -- cyan
local SPEC_ENEMY_COLOR  = { 255, 140, 120, 80 }
local ENEMY_COLOR       = { 255, 220, 50, 50 }  -- red
local LEADER_COLOR      = { 255, 200, 70, 200 } -- purple
local PARTY_COLOR       = { 255, 50, 90, 160 }  -- blue
local ROT_COLOR         = { 255, 255, 140, 0 }  -- orange

---@param name string
---@return string category
local function classify(name)
    local lowered = name:lower()
    local squashed = lowered:gsub('%s+', '')
    if lowered == LAMP_NAME then return 'lamps' end
    if ENEMY_LEADERS[lowered] or ENEMY_LEADERS[squashed] then return 'leaders' end
    if SPECIFIED_ENEMY[lowered] or SPECIFIED_ENEMY[squashed] then return 'specified_enemy' end
    if SPECIFIED_ENEMIES[lowered] or SPECIFIED_ENEMIES[squashed] then return 'specified_enemies' end
    if squashed == 'runeoftransfe' then return 'rune_of_transfer' end
    return 'enemies'
end

---The closest Rune of Transfer in memory, as a one-item list.
---@param player table
---@return table[]
local function rune_of_transfer(player)
    local closest, closest_distance = nil, 300
    for _, mob in pairs(windower.ffxi.get_mob_array()) do
        if mob.name:lower() == RUNE_OF_TRANSFER then
            local distance = map_utils.distance(mob, player)
            if distance < closest_distance then closest, closest_distance = mob, distance end
        end
    end
    return closest and { closest } or {}
end

-- Images are cropped to 220x220 (left=134, top=145 from the original 512x512). Each map is lined up by a
-- known world point (ref_world), its pixel in the cropped image (ref_pixel), and pixels per world unit.
local MAPS              = {
    nyzul_map_1 = {
        image = 'maps/4d_1.png', label = 'Map 1',
        ref_world = { x = 460, y = -443 }, ref_pixel = { x = 122.348, y = 73.066 }, x_scale = 0.39648, y_scale = 0.39648,
    },
    nyzul_map_2 = {
        image = 'maps/4d_2.png', label = 'Map 2',
        ref_world = { x = 580, y = 22 }, ref_pixel = { x = 154.477, y = 79.219 }, x_scale = 0.39648, y_scale = 0.39648,
    },
    nyzul_map_3 = {
        image = 'maps/4d_3.png', label = 'Map 3',
        ref_world = { x = 460, y = 340 }, ref_pixel = { x = 114.828, y = 127.754 }, x_scale = 0.39648, y_scale = 0.39648,
    },
    nyzul_map_4 = {
        image = 'maps/4d_4.png', label = 'Map 4',
        ref_world = { x = 20, y = -298 }, ref_pixel = { x = 122.664, y = 79.219 }, x_scale = 0.39648, y_scale = 0.39648,
    },
    nyzul_map_5 = {
        image = 'maps/4d_5.png', label = 'Map 5',
        ref_world = { x = -60, y = 102 }, ref_pixel = { x = 98.422, y = 93.625 }, x_scale = 0.39648, y_scale = 0.39648,
    },
    nyzul_map_6 = {
        image = 'maps/4d_6.png', label = 'Map 6',
        ref_world = { x = -460, y = -180 }, ref_pixel = { x = 90.902, y = 32.514 }, x_scale = 0.39648, y_scale = 0.39648,
    },
    nyzul_map_8 = {
        image = 'maps/4d_8.png', label = 'Map 8',
        ref_world = { x = -460, y = -180 }, ref_pixel = { x = 90.902, y = 32.514 }, x_scale = 0.39648, y_scale = 0.39648,
    },
}

-- Landmarks for working out which map we're on - the nearest one within proximity_threshold wins.
local AREAS             = {
    name = "Nyzul Isle",
    proximity_threshold = 100, -- Distance threshold for landmark detection
    areas = {
        ["nyzul_map_1"] = {
            landmarks = {
                { x = 460.13,   y = -443.18,  z = -0.00, name = "H7 big room" },
                { x = 517.35,   y = -483.60,  z = 0.00,  name = "I7 room small" },
                { x = 373.40,   y = -496.81,  z = -0.40, name = "G7 left hallway" },
                { x = 431.06,   y = -540.09,  z = 0.00,  name = "H8 Left room" },
                { x = 459.85,   y = -640.15,  z = 0.00,  name = "H9 large room lower" },
                { x = 460.02,   y = -581.64,  z = 0.00,  name = "H8 small room walls middle" },
                { x = 419.98,   y = -578.35,  z = 0.00,  name = "G9/H9 small room walls lower" },
                { x = 374.08,   y = -586.15,  z = -0.40, name = "G9 lower hallway" },
                { x = -9999.24, y = -9999.18, z = -0.40, name = "" },
                { x = -9999.24, y = -9999.18, z = -0.40, name = "" },
                { x = -9999.24, y = -9999.18, z = -0.40, name = "" },


            }
        },
        ["nyzul_map_2"] = {
            landmarks = {
                { x = 579.94, y = -141.78, z = 0.00,  name = "I9 small room walls middle" },
                { x = 539.99, y = -140.10, z = 0.00,  name = "H9/I9 small room no walls" },
                { x = 626.05, y = -146.18, z = -0.40, name = "I9/J9 hallway" },
                { x = 620.57, y = -101.63, z = -0.64, name = "I8/J8/I9/J9/ small room" },
                { x = 620.04, y = -60.06,  z = 0.00,  name = "I8/J8 hallway" },
                { x = 619.94, y = -21.95,  z = -0.50, name = "I7/J7/I8/J8 small room" },
                { x = 626.00, y = 25.99,   z = -0.40, name = "I7/J7/ hallway" },
                { x = 579.89, y = 21.57,   z = 0.00,  name = "I7 small room walls" },
                { x = 540.20, y = 19.99,   z = 0.00,  name = "H7/I7 small room no walls" },
                { x = 440.17, y = -139.97, z = 0.00,  name = "G9" },
                { x = 364.68, y = -139.82, z = -0.40, name = "G9 large room south" },
                { x = 498.40, y = 99.48,   z = -0.72, name = "H6 small room" },
                { x = 399.97, y = 19.58,   z = 0.00,  name = "G7 large room" },

            },
        },
        ["nyzul_map_3"] = {
            landmarks = {
                { x = 459.93, y = 351.31, z = -0.00, name = "H8 top small room empty" },
                { x = 421.67, y = 460.00, z = 0.00,  name = "G7 room walls" },
                { x = 420.41, y = 330.74, z = -0.00, name = "G9 upper hallway" },
                { x = 419.41, y = 297.14, z = 0.00,  name = "G9 small room walls" },
                { x = 417.30, y = 256.16, z = -0.00, name = "G9 lower hallway" },
                { x = 460.06, y = 260.37, z = 0.00,  name = "H9 small room lower" },
                { x = 503.92, y = 257.22, z = -0.00, name = "H9 lower hallway" },
                { x = 498.52, y = 300.47, z = 0.00,  name = "H9 small room right" },
                { x = 461.78, y = 299.72, z = -0.65, name = "H9 small room center" },
                { x = 499.92, y = 338.26, z = 0.00,  name = "H8 small room walls lower" },
                { x = 539.84, y = 340.12, z = 0.00,  name = "I8 small room lower" },
                { x = 585.83, y = 333.84, z = -0.40, name = "I8 lower hallway" },
                { x = 578.22, y = 379.62, z = 0.00,  name = "I8 small room walls right" },
                { x = 585.99, y = 425.92, z = -0.40, name = "I7 upper hallway" },
                { x = 539.96, y = 419.63, z = 0.000, name = "I7/I8 small room no walls upper" },
                { x = 539.16, y = 381.88, z = -0.50, name = "I8 small room no walls middle" },
                { x = 499.82, y = 380.31, z = 0.00,  name = "H8 small room no walls middle" },

            }
        },
        ["nyzul_map_4"] = {
            landmarks = {
                { x = -58.40,   y = -299.67,  z = 0.00,  name = "G7 small room walls left" },
                { x = -66.24,   y = -254.18,  z = -0.40, name = "G6 upper hallway" },
                { x = -19.27,   y = -259.60,  z = 0.00,  name = "H6 small room empty upper" },
                { x = 26.15,    y = -253.96,  z = -0.40, name = "H6 upper hallway" },
                { x = 19.94,    y = -298.33,  z = 0.00,  name = "H7 small room walls" },
                { x = -20.07,   y = -300.30,  z = 0.00,  name = "G7/H7 small room no walls" },
                { x = 18.85,    y = -378.69,  z = -0.79, name = "H8 small room no walls" },
                { x = 13.85,    y = -333.96,  z = -0.40, name = "H7/H8 hallway" },
                { x = 60.10,    y = -338.36,  z = 0.00,  name = "H7/I7/H8/I8 small room walls" },
                { x = 105.89,   y = -334.02,  z = -0.40, name = "I7/I8 hallway" },
                { x = 99.81,    y = -379.97,  z = 0.00,  name = "I8 small room" },
                { x = 105.99,   y = -426.08,  z = -0.40, name = "I8/I9 hallway" },
                { x = -58.09,   y = -460.24,  z = 0.00,  name = "G9 room walls" },
                { x = -19.15,   y = -500.17,  z = 0.00,  name = "G/H 9/10 center of room at bottom" },
                { x = -9999.24, y = -9999.18, z = -0.40, name = "" },
                { x = -9999.24, y = -9999.18, z = -0.40, name = "" },


            }
        },
        ["nyzul_map_5"] = {
            landmarks = {
                { x = -60.22,   y = 101.87,   z = -0.68, name = "G7 upper room no walls" },
                { x = -106.13,  y = 105.88,   z = -0.40, name = "H8 upper hallway" },
                { x = -98.23,   y = 59.97,    z = 0.00,  name = "G8 small room left walls" },
                { x = -106.04,  y = 13.82,    z = -0.40, name = "G9 lower hallway" },
                { x = -61.75,   y = 19.49,    z = -0.50, name = "G9 small room no walls" },
                { x = -19.94,   y = 140.05,   z = -4.00, name = "H7 small room no walls" },
                { x = -20.02,   y = 178.39,   z = -4.00, name = "H6/H7 small room walls" },
                { x = 26.03,    y = 185.95,   z = -4.40, name = "H7 hallway" },
                { x = -66.27,   y = 186.03,   z = -4.40, name = "G7 hallway" },
                { x = 61.54,    y = 60.06,    z = 0.00,  name = "I8 small room walls left" },
                { x = -32.66,   y = -56.63,   z = -3.95, name = "??" },
                { x = -9999.24, y = -9999.18, z = -0.40, name = "" },
                { x = -9999.24, y = -9999.18, z = -0.40, name = "" },
                { x = -9999.24, y = -9999.18, z = -0.40, name = "" },



            }
        },
        ["nyzul_map_6"] = {
            landmarks = {
                { x = -459.93, y = -180.43, z = -4.00, name = "G5 small room middle no walls" },
                { x = -419.85, y = -180.23, z = -4.00, name = "H5 small room no walls right" },
                { x = -500.12, y = -180.07, z = -4.00, name = "F5 small room no walls left" },
                { x = -546.07, y = -174.04, z = -4.40, name = "F7 upper hallway" },
                { x = -466.12, y = -225.90, z = -4.40, name = "G6 hallway" },
                { x = -374.57, y = -214.44, z = -0.40, name = "H6 hallway" },
                { x = -380.00, y = -259.92, z = 0.00,  name = "H6/H7 small room" },
                { x = -334.25, y = -254.08, z = -0.40, name = "H6/I7 hallway" },
                { x = -340.02, y = -299.81, z = 0.00,  name = "H7/I7 small room no walls" },
                { x = -378.43, y = -299.84, z = 0.00,  name = "H7 small room walls" },
                { x = -460.17, y = -380.42, z = 0.00,  name = "G8 small room no walls middle" },
                { x = -461.68, y = -340.12, z = 0.00,  name = "G7/g8 room walls" },
                { x = -459.95, y = -463.59, z = -3.17, name = "G9 hallway" },
                { x = -460.00, y = -498.36, z = -4.00, name = "G9/G10 small room walls" },
                { x = -421.21, y = -500.17, z = -2.50, name = "G9/H9/G10/H10 hallway" },
                { x = -379.91, y = -500.05, z = 0.00,  name = "H9/H10 small room no walls" },
                { x = -334.09, y = -506.01, z = -0.40, name = "H9/I9/H10/I10 hallwaay" },
                { x = -340.12, y = -460.05, z = 0.00,  name = "H9/I9 small room no walls" },
                { x = -378.33, y = -459.96, z = 0.00,  name = "H9 small room walls" },
                { x = -260.02, y = -380.05, z = 0.00,  name = "I/J 8 room" },
                { x = -500.20, y = -579.95, z = -4.00, name = "F/G 10/11" },
                { x = -557.02, y = -423.83, z = -4.00, name = "??" },

            }
        },
        ["nyzul_map_7"] = {
            landmarks = {
                { x = 0, y = 999, z = -900.0, name = "" },
                { x = 0, y = 999, z = -900.0, name = "" },
            }
        },
        ["nyzul_map_8"] = {
            landmarks = {
                { x = 0, y = 999, z = -900.0, name = "" },
                { x = 0, y = 999, z = -900.0, name = "" },
            }
        },
    }
}

---@type MinimapDefinition
return {
    key         = 'nyzul',
    label       = 'Nyzul',
    zones       = { [NYZUL_ZONE] = true },
    asset_dir   = windower.addon_path .. 'nyzul_isle/',
    native_size = 220,
    base_size   = 350,
    areas       = AREAS,
    maps        = MAPS,
    scanner     = Widescan.new('Nyzul', classify, 5),
    layers      = function(player, scan)
        return {
            { name = 'lamp',              kind = 'scan', color = LAMP_COLOR,         size = 4, items = scan:get('lamps') },
            { name = 'specified_enemies', kind = 'scan', color = SPEC_ENEMIES_COLOR, size = 3, items = scan:get('specified_enemies') },
            { name = 'specified_enemy',   kind = 'scan', color = SPEC_ENEMY_COLOR,   size = 3, items = scan:get('specified_enemy') },
            { name = 'enemy',             kind = 'scan', color = ENEMY_COLOR,        size = 3, items = scan:get('enemies') },
            { name = 'leader',            kind = 'scan', color = LEADER_COLOR,       size = 4, items = scan:get('leaders') },
            { name = 'party',             kind = 'live', color = PARTY_COLOR,        size = 3, items = map_utils.get_party_members() },
            { name = 'rune_of_transfer',  kind = 'live', color = ROT_COLOR,          size = 5, items = rune_of_transfer(player) },
        }
    end,
}
