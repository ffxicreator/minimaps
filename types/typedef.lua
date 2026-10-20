---@meta
-- Type Definitions

---@class WindowerSettings
---@field x_res number
---@field y_res number
---@field ui_x_res number
---@field ui_y_res number
---@field launcher_version number
---@field window_x_pos number
---@field window_y_pos number

---@class AbilitiesTable
---@field job_abilities table<number,number>
---@field job_traits table<number,number>
---@field weapon_skills table<number,number>
---@field pet_commands table<number,number>
---@field mounts table<number,number>

---@class BagInfo
---@field enabled boolean
---@field max number
---@field count number

---@class BagInfoTable
---@field inventory BagInfo
---@field safe BagInfo
---@field storage BagInfo
---@field temporary BagInfo
---@field locker BagInfo
---@field satchel BagInfo
---@field sack BagInfo
---@field case BagInfo
---@field wardrobe BagInfo
---@field wardrobe2 BagInfo
---@field wardrobe3 BagInfo
---@field wardrobe4 BagInfo

---@class FFXIInfo
---@field day number
---@field moon number
---@field moon_phase number
---@field time number
---@field zone number
---@field mog_house boolean
---@field logged_in boolean
---@field menu_open boolean
---@field chat_open boolean
---@field weather number
---@field language string
---@field server number
---@field target_arrow Vector3

---@class Vector3
---@field x number
---@field y number
---@field z number

---@class Item
---@field id number
---@field count number
---@field status number
---@field bazaar number
---@field extdata string

---@class BagItems
---@field [number] Item
---@field max number
---@field count number
---@field enabled number

---@class ItemsTable
---@field inventory BagItems
---@field safe BagItems
---@field storage BagItems
---@field temporary BagItems
---@field locker BagItems
---@field satchel BagItems
---@field sack BagItems
---@field case BagItems
---@field wardrobe BagItems
---@field wardrobe2 BagItems
---@field wardrobe3 BagItems
---@field wardrobe4 BagItems
---@field wardrobe5 BagItems
---@field wardrobe6 BagItems
---@field wardrobe7 BagItems
---@field wardrobe8 BagItems
---@field gil number
---@field equipment Equipment

---@class PartyMember
---@field name string
---@field mob table|nil
---@field hp number
---@field hpp number
---@field mp number
---@field mpp number
---@field tp number
---@field zone number

---@class PartyTable
---@field p0 PartyMember
---@field p1? PartyMember
---@field p2? PartyMember
---@field p3? PartyMember
---@field p4? PartyMember
---@field p5? PartyMember
---@field a10? PartyMember
---@field a11? PartyMember
---@field a12? PartyMember
---@field a13? PartyMember
---@field a14? PartyMember
---@field a15? PartyMember
---@field a20? PartyMember
---@field a21? PartyMember
---@field a22? PartyMember
---@field a23? PartyMember
---@field a24? PartyMember
---@field a25? PartyMember
---@field party1_leader number|nil
---@field party2_leader number|nil
---@field party3_leader number|nil
---@field alliance_leader number|nil
---@field party1_count number
---@field party2_count number
---@field party3_count number
---@field alliance_count number

---@class PlayerVitals
---@field hp number
---@field mp number
---@field max_hp number
---@field max_mp number
---@field hpp number
---@field mpp number
---@field tp number

---@class Mob
---@field name string
---@field id number
---@field index number
---@field claim_id number
---@field x number
---@field y number
---@field z number
---@field distance number
---@field facing number
---@field status number
---@field hpp number
---@field target_index number
---@field pet_index number|nil
---@field valid_target boolean
---@field target_type number
---@field spawn_type number
---@field animation_speed number
---@field race number
---@field is_npc boolean
---@field in_party boolean
---@field charmed boolean
---@field movement_speed number
---@field model_size number
---@field heading number --direction this mob is facing or going? not sure
---@field models table --{[1]=51}
---@field in_alliance boolean


---@class Skills
---@field alchemy number
---@field bonecraft number
---@field clothcraft number
---@field cooking number
---@field fishing number
---@field goldsmithing number
---@field leathercraft number
---@field smithing number
---@field woodworking number
---@field synergy number

---@class Jobs
---@field WAR number
---@field MNK number
---@field WHM number
---@field BLM number
---@field RDM number
---@field THF number
---@field PLD number
---@field DRK number
---@field BST number
---@field BRD number
---@field RNG number
---@field SAM number
---@field NIN number
---@field DRG number
---@field SMN number
---@field BLU number
---@field COR number
---@field PUP number
---@field DNC number
---@field SCH number
---@field GEO number
---@field RUN number

---@class Merits
---@field str number
---@field dex number
---@field vit number
---@field agi number
---@field int number
---@field mnd number
---@field chr number

---@class JobPoints
---@field jp number
---@field cp number
---@field jp_spent number
---@field aggressor_effect number
---@field [string] number

---@class JobPointsTable
---@field war JobPoints
---@field mnk JobPoints
---@field whm JobPoints
---@field blm JobPoints
---@field rdm JobPoints
---@field thf JobPoints
---@field pld JobPoints
---@field drk JobPoints
---@field bst JobPoints
---@field brd JobPoints
---@field rng JobPoints
---@field sam JobPoints
---@field nin JobPoints
---@field drg JobPoints
---@field smn JobPoints
---@field blu JobPoints
---@field cor JobPoints
---@field pup JobPoints
---@field dnc JobPoints
---@field sch JobPoints
---@field geo JobPoints
---@field run JobPoints

---@class AutoRun
---@field x number
---@field y number
---@field z number

---@class Player
---@field id number
---@field name string
---@field buffs number[]
---@field skills Skills
---@field vitals PlayerVitals
---@field jobs Jobs
---@field merits Merits
---@field job_points JobPointsTable
---@field linkshell string
---@field linkshell_rank number
---@field linkshell_slot number
---@field main_job string
---@field main_job_level number
---@field main_job_full string
---@field main_job_id number
---@field superior_level number
---@field nation number
---@field status number
---@field item_level number
---@field index number
---@field sub_job string
---@field sub_job_level number
---@field sub_job_full string
---@field sub_job_id number
---@field target_index number
---@field in_combat boolean
---@field target_locked boolean
---@field autorun AutoRun | boolean
---@field follow_index number
---@field master_levels table

---@alias EventName
---| 'load' # () => void
---| 'unload' # () => void
---| 'login' # (name: string) => void
---| 'logout' # (name: string) => void
---| 'gain focus' # () => void
---| 'lose focus' # () => void
---| 'gain buff' # (buff_id: number) => void
---| 'lose buff' # (buff_id: number) => void
---| 'gain experience' # (amount: number, chain_number: number, limit: boolean) => void
---| 'lose experience' # (amount: number) => void
---| 'level up' # (level: number) => void
---| 'level down' # (level: number) => void
---| 'job change' # (main_job_id: number, main_job_level: number, sub_job_id: number, sub_job_level: number) => void
---| 'target change' # (index: number) => void
---| 'weather change' # (weather_id: number) => void
---| 'status change' # (new_status_id: number, old_status_id: number) => void
---| 'hp change' # (new_hp: number, old_hp: number) => void
---| 'mp change' # (new_mp: number, old_mp: number) => void
---| 'tp change' # (new_tp: number, old_tp: number) => void
---| 'hpp change' # (new_hpp: number, old_hpp: number) => void
---| 'mpp change' # (new_mpp: number, old_mpp: number) => void
---| 'hpmax change' # (new_hp_max: number, old_hp_max: number) => void
---| 'mpmax change' # (new_mp_max: number, old_mp_max: number) => void
---| 'chat message' # (message: string, sender: string, mode: number, gm: boolean) => void
---| 'emote' # (emote_id: number, sender_id: number, target_id: number, motion: boolean) => void
---| 'party invite' # (sender: string, sender_id: number) => void
---| 'examined' # (name: string, sender_index: number) => void
---| 'time change' # (new: number, old: number) => void
---| 'day change' # (new_day: number, old_day: number) => void
---| 'moon change' # (new_moon: string, old_moon: string) => void
---| 'linkshell change' # (new_ls: string, old_ls: string) => void
---| 'zone change' # (new_id: number, old_id: number) => void
---| 'add item' # (bag: number, index: number, id: number, count: number) => void
---| 'remove item' # (bag: number, index: number, id: number, count: number) => void
---| 'incoming text' # (original: string, modified: string, original_mode: number, modified_mode: number, blocked: boolean) => string|boolean|nil
---| 'incoming chunk' # (id: number, original: string, modified: string, injected: boolean, blocked: boolean) => string|boolean|nil
---| 'outgoing text' # (original: string, modified: string, blocked: boolean) => string|boolean|nil
---| 'outgoing chunk' # (id: number, original: string, modified: string, injected: boolean, blocked: boolean) => string|boolean|nil
---| 'mouse' # (type: number, x: number, y: number, delta: number, blocked: number) => boolean|nil
---| 'keyboard' # (dik: number, pressed: boolean, flags: number, blocked: boolean) => boolean|nil
---| 'ipc message' # (message: string) => void
---| 'addon command' # (...: string) => void
---| 'unhandled command' # (...: string) => void
---| 'pipe message' # (message: string) => void
---| 'prerender' # () => void
---| 'postrender' # () => void

---@class Equipment
---@field main number Slot number for main hand weapon
---@field main_bag number Bag ID for main hand weapon
---@field sub number Slot number for sub hand weapon/shield
---@field sub_bag number Bag ID for sub hand weapon/shield
---@field range number Slot number for ranged weapon
---@field range_bag number Bag ID for ranged weapon
---@field ammo number Slot number for ammunition
---@field ammo_bag number Bag ID for ammunition
---@field head number Slot number for head equipment
---@field head_bag number Bag ID for head equipment
---@field neck number Slot number for neck equipment
---@field neck_bag number Bag ID for neck equipment
---@field left_ear number Slot number for left ear equipment
---@field left_ear_bag number Bag ID for left ear equipment
---@field right_ear number Slot number for right ear equipment
---@field right_ear_bag number Bag ID for right ear equipment
---@field body number Slot number for body equipment
---@field body_bag number Bag ID for body equipment
---@field hands number Slot number for hands equipment
---@field hands_bag number Bag ID for hands equipment
---@field left_ring number Slot number for left ring
---@field left_ring_bag number Bag ID for left ring
---@field right_ring number Slot number for right ring
---@field right_ring_bag number Bag ID for right ring
---@field back number Slot number for back equipment
---@field back_bag number Bag ID for back equipment
---@field waist number Slot number for waist equipment
---@field waist_bag number Bag ID for waist equipment
---@field legs number Slot number for legs equipment
---@field legs_bag number Bag ID for legs equipment
---@field feet number Slot number for feet equipment
---@field feet_bag number Bag ID for feet equipment


--[[
Example Action Packet Structure (Immanence self-buff):
{
    ["targets"]={
        [1]={
            ["id"]=303074,  -- Target entity ID (self in this case)
            ["actions"]={
                [1]={
                    ["spike_effect_param"]=0,
                    ["add_effect_message"]=0,      -- Skillchain message ID (288-301, 767-770 for SCs)
                    ["message"]=100,               -- Primary action message ID (100 = buff applied)
                    ["param"]=470,                 -- Status effect ID (Immanence buff)
                    ["reaction"]=16,
                    ["add_effect_param"]=0,        -- Skillchain damage if applicable
                    ["stagger"]=0,
                    ["unknown"]=0,
                    ["add_effect_effect"]=0,
                    ["spike_effect_effect"]=0,
                    ["has_spike_effect"]=false,
                    ["spike_effect_animation"]=0,
                    ["animation"]=245,             -- Animation ID
                    ["knockback"]=0,
                    ["add_effect_animation"]=0,
                    ["spike_effect_message"]=0,
                },
            },
            ["action_count"]=1,
        },
    },
    ["unknown"]=0,
    ["target_count"]=1,
    ["recast"]=0,
    ["actor_id"]=303074,  -- Entity performing the action (self)
    ["param"]=317,        -- Job Ability ID (Immanence)
    ["category"]=6,       -- Action category (6 = Job Ability)
}

For comparison - Weaponskill causing a skillchain:
{
    ["targets"]={
        [1]={
            ["id"]=123456,  -- Enemy target
            ["actions"]={
                [1]={
                    ["add_effect_message"]=291,  -- Fragmentation skillchain
                    ["message"]=2,               -- Normal weaponskill hit
                    ["param"]=1250,              -- Damage dealt
                    ["add_effect_param"]=450,    -- Skillchain damage
                    ["animation"]=623,
                    -- ... other fields ...
                },
            },
        },
    },
    ["actor_id"]=303074,
    ["param"]=160,        -- Weaponskill ID (e.g., Tachi: Gekko)
    ["category"]=3,       -- Weaponskill finish
}
--]]
---@class GameState
---@field player_info          Mob
---@field player               Player
---@field zone                 number
---@field under_manual_control boolean
---@field target               Mob | nil

---@class ActionPacketAction
---@field spike_effect_param number
---@field add_effect_message number Message ID for additional effects (like skillchain type)
---@field message number Primary message ID that describes the action result
---@field param number Primary parameter (damage amount, spell ID, etc.)
---@field reaction number Reaction flags (hit/miss/evade/etc.)
---@field add_effect_param number Parameter for additional effect (damage/value)
---@field stagger number Stagger value
---@field unknown number Unknown field
---@field add_effect_effect number Additional effect type
---@field spike_effect_effect number Spike effect type
---@field has_spike_effect boolean Whether spike effect occurred
---@field spike_effect_animation number Animation ID for spike effect
---@field animation number Primary animation ID
---@field knockback number Knockback distance/flags
---@field add_effect_animation number Animation ID for additional effect
---@field spike_effect_message number Message ID for spike effect

---@class ActionPacketTarget
---@field id number The target entity's server ID
---@field actions ActionPacketAction[] Array of actions performed on this target
---@field action_count number Number of actions in the actions array

---@class ActionPacket
---@field targets ActionPacketTarget[] Array of targets affected by this action
---@field unknown number Unknown field (appears twice in packet)
---@field target_count number Number of targets in the targets array
---@field recast number Recast/cooldown related value
---@field actor_id number The entity ID of the actor performing the action
---@field param number Top-level parameter (often ability/spell/ws ID)
---@field category number Action category (weaponskill, spell, job ability, etc.)
