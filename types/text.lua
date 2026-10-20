---@meta
require('types.core')

-- Text Namespace
---@class TextNamespace
windower.text = {}

---@param name string Name of text object
function windower.text.create(name) end

---@param name string Name of text object
function windower.text.delete(name) end

---@param name string Name of text object
---@return number width, number height Size of text object
function windower.text.get_extents(name) end

---@param name string Name of text object
---@return number x, number y Position of text object
function windower.text.get_location(name) end

---@param name string Name of text object
---@param px number Border size in pixels
function windower.text.set_bg_border_size(name, px) end

---@param name string Name of text object
---@param alpha number Alpha value (0-255)
---@param red number Red value (0-255)
---@param green number Green value (0-255)
---@param blue number Blue value (0-255)
function windower.text.set_bg_color(name, alpha, red, green, blue) end

---@param name string Name of text object
---@param visible boolean Visibility
function windower.text.set_bg_visibility(name, visible) end

---@param name string Name of text object
---@param bold boolean Bold state
function windower.text.set_bold(name, bold) end

---@param name string Name of text object
---@param alpha number Alpha value (0-255)
---@param red number Red value (0-255)
---@param green number Green value (0-255)
---@param blue number Blue value (0-255)
function windower.text.set_color(name, alpha, red, green, blue) end

---@param name string Name of text object
---@param font string Font name
function windower.text.set_font(name, font) end

---@param name string Name of text object
---@param size number Font size
function windower.text.set_font_size(name, size) end

---@param name string Name of text object
---@param italic boolean Italic state
function windower.text.set_italic(name, italic) end

---@param name string Name of text object
---@param x number Horizontal position
---@param y number Vertical position
function windower.text.set_location(name, x, y) end

---@param name string Name of text object
---@param justified boolean Right justified state
function windower.text.set_right_justified(name, justified) end

---@param name string Name of text object
---@param alpha number Alpha value (0-255)
---@param red number Red value (0-255)
---@param green number Green value (0-255)
---@param blue number Blue value (0-255)
function windower.text.set_stroke_color(name, alpha, red, green, blue) end

---@param name string Name of text object
---@param width number Stroke width in pixels
function windower.text.set_stroke_width(name, width) end

---@param name string Name of text object
---@param text string Text to display
function windower.text.set_text(name, text) end

---@param name string Name of text object
---@param visible boolean Visibility
function windower.text.set_visibility(name, visible) end

-- Primitive Namespace
---@class PrimNamespace
windower.prim = {}

---@param name string Name of primitive
function windower.prim.create(name) end

---@param name string Name of primitive
function windower.prim.delete(name) end

---@param name string Name of primitive
---@param alpha number Alpha value (0-255)
---@param red number Red value (0-255)
---@param green number Green value (0-255)
---@param blue number Blue value (0-255)
function windower.prim.set_color(name, alpha, red, green, blue) end

---@param name string Name of primitive
---@param fit boolean FitToTexture state
function windower.prim.set_fit_to_texture(name, fit) end

---@param name string Name of primitive
---@param x number X position
---@param y number Y position
function windower.prim.set_position(name, x, y) end

---@param name string Name of primitive
---@param x number X size
---@param y number Y size
function windower.prim.set_size(name, x, y) end

---@param name string Name of primitive
---@param texture string Absolute path to texture file
function windower.prim.set_texture(name, texture) end

---@param name string Name of primitive
---@param x number X repetition value
---@param y number Y repetition value
function windower.prim.set_repeat(name, x, y) end

---@param name string Name of primitive
---@param visible boolean Visibility
function windower.prim.set_visibility(name, visible) end