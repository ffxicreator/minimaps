---@meta
require('types.core')

-- Chat Namespace
---@class ChatNamespace
windower.chat = {}

---@param text string Text to add
---@param position? number Position to add text at
function windower.chat.add_to_input(text, position) end

---@return string text, number position Current input text and cursor position
function windower.chat.get_input() end

---@param text string Text to input
function windower.chat.input(text) end

---@return boolean is_open Whether chat box is open
function windower.chat.is_open() end

function windower.chat.paste() end

---@param text string New input text
---@param position? number New cursor position
function windower.chat.set_input(text, position) end