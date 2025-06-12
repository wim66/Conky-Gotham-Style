-- background.lua
-- Conky-Gotham-Style
-- by @wim66
-- 12 June 2025

-- === Required Cairo Modules ===
require("cairo")
local status, cairo_xlib = pcall(require, "cairo_xlib")

if not status then
  cairo_xlib = setmetatable({}, {
    __index = function(_, k)
      return _G[k]
    end,
  })
end

-- === Utility ===
local unpack = table.unpack or unpack

boxes_settings = {
  -- Background
  {
    type = "background",
    x = 0,
    y = 0,
    w = 460,
    h = 116,
    centre_x = true,
    corners = { 20, 20, 20, 20 },
    draw_me = true,
    colour = { { 1, 0x00051a, 1 } },
  },

  -- Second background layer with linear gradient
  {
    type = "layer2",
    x = 0,
    y = 0,
    w = 418,
    h = 256,
    centre_x = true,
    corners = { 20, 20, 20, 20 },
    draw_me = false,
    linear_gradient = { 0, 0, 0, 200 },
    colours = { { 0, 0xFFFFFF, 0.05 }, { 0.5, 0xC2C2C2, 0.1 }, { 1, 0xFFFFFF, 0.05 } },
  },

  -- Border
  {
    type = "border",
    x = 0,
    y = 0,
    w = 460,
    h = 116,
    centre_x = true,
    corners = { 20, 20, 20, 20 },
    draw_me = true,
    border = 4,
    colour = { { 0, 0x999999, 0.33 }, { 0.5, 0xffffff, 1 }, { 1, 0x999999, 0.33 } },
    linear_gradient = { 0, 0, 440, 0 },
  },
}

local function hex_to_rgba(hex, alpha)
  return ((hex >> 16) & 0xFF) / 255, ((hex >> 8) & 0xFF) / 255, (hex & 0xFF) / 255, alpha
end

local function draw_custom_rounded_rectangle(cr, x, y, w, h, r)
  local tl, tr, br, bl = unpack(r)
  cairo_new_path(cr)
  cairo_move_to(cr, x + tl, y)
  cairo_line_to(cr, x + w - tr, y)
  if tr > 0 then
    cairo_arc(cr, x + w - tr, y + tr, tr, -math.pi / 2, 0)
  else
    cairo_line_to(cr, x + w, y)
  end
  cairo_line_to(cr, x + w, y + h - br)
  if br > 0 then
    cairo_arc(cr, x + w - br, y + h - br, br, 0, math.pi / 2)
  else
    cairo_line_to(cr, x + w, y + h)
  end
  cairo_line_to(cr, x + bl, y + h)
  if bl > 0 then
    cairo_arc(cr, x + bl, y + h - bl, bl, math.pi / 2, math.pi)
  else
    cairo_line_to(cr, x, y + h)
  end
  cairo_line_to(cr, x, y + tl)
  if tl > 0 then
    cairo_arc(cr, x + tl, y + tl, tl, math.pi, 3 * math.pi / 2)
  else
    cairo_line_to(cr, x, y)
  end
  cairo_close_path(cr)
end

local function get_centered_x(canvas_width, box_width)
  return (canvas_width - box_width) / 2
end

function conky_draw_background()
  if conky_window == nil then
    return
  end

  local cs =
    cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
  local cr = cairo_create(cs)
  local canvas_width = conky_window.width

  for _, box in ipairs(boxes_settings) do
    if box.draw_me then
      local x, y, w, h = box.x, box.y, box.w, box.h
      if box.centre_x then
        x = get_centered_x(canvas_width, w)
      end

      local cx, cy = x + w / 2, y + h / 2
      local angle = (box.rotation or 0) * math.pi / 180
      local skew_x = (box.skew_x or 0) * math.pi / 180 -- Convert degrees to radians
      local skew_y = (box.skew_y or 0) * math.pi / 180 -- Convert degrees to radians

      -- Save context and apply transformations
      cairo_save(cr)
      cairo_translate(cr, cx, cy)
      cairo_rotate(cr, angle)
      -- Apply skew transformation
      local matrix = cairo_matrix_t:create()
      cairo_matrix_init(matrix, 1, math.tan(skew_y), math.tan(skew_x), 1, 0, 0)
      cairo_transform(cr, matrix)
      cairo_translate(cr, -cx, -cy)

      if box.type == "background" then
        cairo_set_source_rgba(cr, hex_to_rgba(box.colour[1][2], box.colour[1][3]))
        draw_custom_rounded_rectangle(cr, x, y, w, h, box.corners)
        cairo_fill(cr)
      elseif box.type == "layer2" then
        local grad = cairo_pattern_create_linear(unpack(box.linear_gradient))
        for _, color in ipairs(box.colours) do
          cairo_pattern_add_color_stop_rgba(grad, color[1], hex_to_rgba(color[2], color[3]))
        end
        cairo_set_source(cr, grad)
        draw_custom_rounded_rectangle(cr, x, y, w, h, box.corners)
        cairo_fill(cr)
        cairo_pattern_destroy(grad)
      elseif box.type == "border" then
        local grad = cairo_pattern_create_linear(unpack(box.linear_gradient))
        for _, color in ipairs(box.colour) do
          cairo_pattern_add_color_stop_rgba(grad, color[1], hex_to_rgba(color[2], color[3]))
        end
        cairo_set_source(cr, grad)
        cairo_set_line_width(cr, box.border)
        draw_custom_rounded_rectangle(cr, x + box.border / 2, y + box.border / 2, w - box.border, h - box.border, {
          math.max(0, box.corners[1] - box.border / 2),
          math.max(0, box.corners[2] - box.border / 2),
          math.max(0, box.corners[3] - box.border / 2),
          math.max(0, box.corners[4] - box.border / 2),
        })
        cairo_stroke(cr)
        cairo_pattern_destroy(grad)
      end

      cairo_restore(cr)
    end
  end

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
end
