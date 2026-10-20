---@meta
require('types.typedef')

---@class Windower
---@field ffxi FFXINamespace
---@field packets PacketNamespace
---@field text TextNamespace
---@field prim PrimNamespace
---@field chat ChatNamespace
---@field console ConsoleNamespace
---@field regex RegexNamespace
---@field windower_path string Path to current Windower installation (includes final slash)
---@field addon_path string Path to currently loaded addon directory (includes final slash)
---@field pol_path string Path to playonline and ffxi install directory (includes final slash)

windower = {}

-- Core windower functions
---@param mode integer Chatmode to use
---@param msg string Message to write
function windower.add_to_chat(mode, msg) end

---@param path string The path to the folder
function windower.create_dir(path) end

---@param str string Input string containing auto-translated blocks
---@return string str String with auto-translate formatting removed
function windower.convert_auto_trans(str) end

---@param str string String to copy
function windower.copy_to_clipboard(str) end

---@param ... any Any number/type of arguments to be printed
function windower.debug(...) end

---@param path string The path to the folder
---@return boolean exists Whether directory exists
function windower.dir_exists(path) end

---@param file string The path to the file
---@param arguments table List of arguments to pass
function windower.execute(file, arguments) end

---@param path string The path to the file
---@return boolean exists Whether file exists
function windower.file_exists(path) end

---@param str string Input string containing %-variables
---@return string formatted String with variables replaced
function windower.format_variables(str) end

---@param str string The string to convert
---@return string converted String converted from Shift_JIS to UTF-8
function windower.from_shift_jis(str) end

---@param path string The path to the directory
---@return table dir_contents Table containing files and directories
function windower.get_dir(path) end

---@return string|nil clipboard_contents Contents of clipboard if applicable
function windower.get_from_clipboard() end

---@return table filters Current ingame chat filters
function windower.get_chat_filters() end

---@return WindowerSettings settings Table of Windower settings
function windower.get_windower_settings() end

---@param url string URL to open in browser
function windower.open_url(url) end

---@param path string Path to sound file (.wav)
function windower.play_sound(path) end

---Register an event handler
---@param event EventName Name of the event to register
---@param handler function The handler function for the event
---@return number event_id Returns ID that can be used to unregister the event
function windower.register_event(event, handler) end

---@param str string Command to send (without //)
function windower.send_command(str) end

---@param msg string Message to send to other Windower instances
function windower.send_ipc_message(msg) end

---@param id number ID of the mob
---@param name string New name for the mob
function windower.set_mob_name(id, name) end

---@param str string UTF-8 string to convert
---@return string converted String converted to Shift_JIS
function windower.to_shift_jis(str) end

---@param id number ID of event to unregister
function windower.unregister_event(id) end

---@param str string Input string to match
---@param pattern string Pattern to match against
---@return boolean matches Whether string matches pattern
function windower.wc_match(str, pattern) end

---@return boolean has_focus Whether instance has focus
function windower.has_focus() end

---Windower extension: schedules a function to run after a delay, without blocking.
---@param fn function Function to call once the delay elapses
---@param delay number Delay in seconds
---@return number coroutine_id Can be passed to coroutine.close to cancel
function coroutine.schedule(fn, delay) end

---Windower extension: cancels a coroutine scheduled via coroutine.schedule.
---@param coroutine_id number
function coroutine.close(coroutine_id) end

function windower.take_focus() end

---@return table camera not sure what the actual object looks like
function windower.get_camera() end
