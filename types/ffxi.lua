---@meta

require('types.core')

-- FFXI Namespace
---@class FFXINamespace
windower.ffxi = {}

---@param id number ID of the buff to cancel
function windower.ffxi.cancel_buff(id) end

---@param index number Inventory index of item
---@param count? number Number of items to drop
function windower.ffxi.drop_item(index, count) end

---@param index? number Index of target to follow. If nil, stops following
function windower.ffxi.follow(index) end

---@return AbilitiesTable abilities Table containing job abilities, traits, weapon skills and pet commands
function windower.ffxi.get_abilities() end

---@return table recast_times Table of current ability recast times
function windower.ffxi.get_ability_recasts() end

---@param bag? number ID of the bag to get info for
---@return BagInfo|BagInfoTable bag_info Bag info for specified bag or all bags
function windower.ffxi.get_bag_info(bag) end

---@return FFXIInfo info FFXI related info
function windower.ffxi.get_info() end

---@param bag number ID of the bag
---@param slot number Slot in the bag
---@param count? number Number of items to transfer
function windower.ffxi.get_item(bag, slot, count) end

---@param bag? string | number Specify which inventory bag
---@param index? number Specify which item from bag
---@return ItemsTable|BagItems|Item items Items table based on parameters
function windower.ffxi.get_items(bag, index) end

---@return number[] key_items List of available key item IDs
function windower.ffxi.get_key_items() end

---@param index_or_x? number|nil Index of mob or X coordinate
---@param y? number Y coordinate if using coordinates
---@param z? number Z coordinate if using coordinates
---@return number map_id, number x, number y Map data
function windower.ffxi.get_map_data(index_or_x, y, z) end

---@return table mjob_data Main job specific data
function windower.ffxi.get_mjob_data() end

---@param id number Full ID of mob to look up
---@return Mob|nil mob Mob information if found
function windower.ffxi.get_mob_by_id(id) end

---@param index number Index in mob array
---@return Mob|nil mob Mob information if found
function windower.ffxi.get_mob_by_index(index) end

---@param name string Name of mob to look up
---@return Mob|nil mob Mob information if found
function windower.ffxi.get_mob_by_name(name) end

---@param target string Target variable (me,t,bt etc)
---@return Mob|nil mob Mob information if found
function windower.ffxi.get_mob_by_target(target) end

---@return table<string,Mob> mobs All mob tables in memory
function windower.ffxi.get_mob_array() end

---@param id number ID of mob to look up
---@return string name Name of mob with provided ID
function windower.ffxi.get_mob_name(id) end

---@return PartyTable party Data on the party
function windower.ffxi.get_party() end

---@return Player player Player info
function windower.ffxi.get_player() end

---@param index number Index of mob
---@param x number X coordinate
---@param y number Y coordinate
---@param z number Z coordinate
---@return string position In-game position string
function windower.ffxi.get_position(index, x, y, z) end

---@return table sjob_data Sub job specific data
function windower.ffxi.get_sjob_data() end

---@return table recast_times Table of spell recast times
function windower.ffxi.get_spell_recasts() end

---@return table spells Table of learned spells
function windower.ffxi.get_spells() end

---@param slot number Slot in treasure pool
function windower.ffxi.lot_item(slot) end

---@param slot number Slot in treasure pool
function windower.ffxi.pass_item(slot) end

---@param bag number ID of bag to store in
---@param slot number Inventory slot
---@param count? number Number of items to transfer
function windower.ffxi.put_item(bag, slot, count) end

---@param index number Slot of spell to remove
function windower.ffxi.remove_blue_magic_spell(index) end

function windower.ffxi.reset_attachments() end

function windower.ffxi.reset_blue_magic_spells() end

---@param run? boolean|number Start/stop running or direction in radians
function windower.ffxi.run(run) end

---@param id number Item ID of attachment
---@param slot number Slot to equip in
function windower.ffxi.set_attachment(id, slot) end

---@param id number Spell ID
---@param slot number Slot number
function windower.ffxi.set_blue_magic_spell(id, slot) end

---@param inv_id number ID in inventory
---@param slot number Equipment slot ID
---@param bag number Inventory bag
function windower.ffxi.set_equip(inv_id, slot, bag) end

---@param walk boolean true for walk, false for run
function windower.ffxi.toggle_walk(walk) end

---@param dir number Radian angle to turn to
function windower.ffxi.turn(dir) end
