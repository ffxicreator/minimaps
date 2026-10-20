---@meta

---@class Addon
---@field name string The name of the addon
---@field author string The author of the addon
---@field version string The version of the addon
---@field command string The primary command used to interact with the addon
---@field commands? string[] Additional commands for the addon

---@type Addon
 _addon = {
    name = '',
    author = '',
    version = '',
    command = ''
}