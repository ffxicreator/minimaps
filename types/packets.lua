---@meta

require('types.core')

-- Packets Namespace
---@class PacketNamespace
windower.packets = {}

---@param id number Packet ID
---@param data string Binary packet data
function windower.packets.inject_incoming(id, data) end

---@param id number Packet ID
---@param data string Binary packet data
function windower.packets.inject_outgoing(id, data) end

---@param id number Packet ID
---@return string|nil packet, number|nil timestamp Last received packet and timestamp
function windower.packets.last_incoming(id) end

---@param id number Packet ID
---@return string|nil packet, number|nil timestamp Last sent packet and timestamp
function windower.packets.last_outgoing(id) end

---@param data string Binary packet data
---@return table parsed_data Parsed action packet data
function windower.packets.parse_action(data) end

---@class ActionMessagePacket
---@field Actor              number  Actor entity ID
---@field ["Actor Index"]    number  Actor entity index
---@field Target             number  Target entity ID
---@field ["Target Index"]   number  Target entity index
---@field Message            number  Message ID
---@field ["Param 1"]        number
---@field ["Param 2"]        number
---@field _id                number  Packet ID (41 = 0x29)
---@field _name              string
---@field _description       string
---@field _dir               string
---@field _sequence          number
---@field _size              number
---@field _raw               string
---@field _aliases           table
---@field _args              table
---@field _unknown1          number