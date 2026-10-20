---@meta
require('types.core')

-- Console Namespace
---@class ConsoleNamespace
windower.console = {}

function windower.console.clear() end

function windower.console.close() end

function windower.console.open() end

---@param x number Horizontal position in pixels
---@param y number Vertical position in pixels
function windower.console.set_position(x, y) end

---@return boolean visible Whether console is visible
function windower.console.visible() end

---@param text string Text to write to console
function windower.console.write(text) end

-- Regex Namespace
---@class RegexNamespace
windower.regex = {}

---@param str string String to search
---@param pattern string Regular expression pattern
---@return table|nil matches Table of matches if found
function windower.regex.match(str, pattern) end

---@param str string String to search
---@param pattern string Regular expression pattern
---@param replace string|table|function Replacement
---@return string replaced String with matches replaced
function windower.regex.replace(str, pattern, replace) end

---@param str string String to split
---@param pattern string Regular expression pattern
---@return string[] parts String split on pattern
function windower.regex.split(str, pattern) end