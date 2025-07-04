-- text.lua
-- Conky-Gotham-Style
-- by @wim66
-- 12 June 2025

--[[TEXT WIDGET v1.42 by Wlourf 07 Feb. 2011

This widget can drawn texts set in the "text_settings" table with some parameters
http://u-scripts.blogspot.com/2010/06/text-widget.html

To call the script in a conky, use, before TEXT
	lua_load /path/to/the/script/graph.lua
	lua_draw_hook_pre main_graph
and add one line (blank or not) after TEXT

The parameters (all optionals) are :
text        - text to display, default = "Conky is good for you"
              it can be used with conky variables, i.e. text="my cpu1 is ${cpu cpu1} %")
            - coordinates below are relative to top left corner of the conky window
x           - x coordinate of first letter (bottom-left), default = center of conky window
y           - y coordinate of first letter (bottom-left), default = center of conky window
h_align		- horizontal alignement of text relative to point (x,y), default="l"
			  available values are "l": left, "c" : center, "r" : right
v_align		- vertical alignment of text relative to point (x,y), default="b"
			  available values "t" : top, "m" : middle, "b" : bottom
font_name   - name of font to use, default = Free Sans
font_size   - size of font to use, default = 14
italic      - display text in italic (true/false), default=false
oblique     - display text in oblique (true/false), default=false (I don' see the difference with italic!)
bold        - display text in bold (true/false), default=false
angle       - rotation of text in degrees, default = 0 (horizontal)
colour      - table of colours for text, default = plain white {{1,0xFFFFFF,1}}
			  this table contains one or more tables with format {P,C,A}
              P=position of gradient (0 = beginning of text, 1= end of text)
              C=hexadecimal colour
              A=alpha (opacity) of color (0=invisible,1=opacity 100%)
              Examples :
              for a plain color {{1,0x00FF00,0.5}}
              for a gradient with two colours {{0,0x00FF00,0.5},{1,0x000033,1}}
              or {{0.5,0x00FF00,1},{1,0x000033,1}} -with this one, gradient will start in the middle of the text
              for a gradient with three colours {{0,0x00FF00,0.5},{0.5,0x000033,1},{1,0x440033,1}}
			  and so on ...
orientation	- in case of gradient, "orientation" defines the starting point of the gradient, default="ww"
			  there are 8 available starting points : "nw","nn","ne","ee","se","ss","sw","ww"
			  (n for north, w for west ...)
			  theses 8 points are the 4 corners + the 4 middles of text's outline
			  so a gradient "nn" will go from "nn" to "ss" (top to bottom, parallele to text)
			  a gradient "nw" will go from "nw" to "se" (left-top corner to right-bottom corner)
radial		- define a radial gradient (if present at the same time as "orientation", "orientation" will have no effect)
			  this parameter is a table with 6 numbers : {xa,ya,ra,xb,yb,rb}
			  they define two circle for the gradient :
			  xa, ya, xb and yb are relative to x and y values above
reflection_alpha    - add a reflection effect (values from 0 to 1) default = 0 = no reflection
                      other values = starting opacity
reflection_scale    - scale of the reflection (default = 1 = height of text)
reflection_length   - length of reflection, define where the opacity will be set to zero
					  calues from 0 to 1, default =1
skew_x,skew_y    - skew text around x or y axis
draw_me     - if set to false, text is not drawn (default = true or 1)
              it can be used with a conky string, if the string returns 1, the text is drawn :
              example : "${if_empty ${wireless_essid wlan0}}${else}1$endif",



v1.0	07/06/2010, Original release
v1.1	10/06/2010	Add "orientation" parameter
v1.2	15/06/2010  Add "h_align", "v_align" and "radial" parameters
v1.3	25/06/2010  Add "reflection_alpha", "reflection_length", "reflection_scale",
                    "skew_x" et "skew_y"
v1.4    07/01/2011  Add draw_me parameter and correct memory leaks, thanks to "Creamy Goodness"
                    text is parsed inside the function, not in the array of settings
v1.41   26/01/2011  Correct bug for h_align="c"
v1.42   09/02/2011  Correct bug for orientation="ee"

--      This program is free software; you can redistribute it and/or modify
--      it under the terms of the GNU General Public License as published by
--      the Free Software Foundation version 3 (GPLv3)
--
--      This program is distributed in the hope that it will be useful,
--      but WITHOUT ANY WARRANTY; without even the implied warranty of
--      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--      GNU General Public License for more details.
--
--      You should have received a copy of the GNU General Public License
--      along with this program; if not, write to the Free Software
--      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
--      MA 02110-1301, USA.

]]
-- === Required Cairo Modules ===
require("cairo")
local status, cairo_xlib = pcall(require, "cairo_xlib")

if not status then
  -- Fallback for environments without cairo_xlib
  cairo_xlib = setmetatable({}, {
    __index = function(_, key)
      return _G[key]
    end,
  })
end

function conky_draw_text()
  --BEGIN OF PARAMETRES
  if conky_window == nil then
    return
  end
  local w = conky_window.width
  local h = conky_window.height
  local xc = w / 2
  local yc = h / 2
  local color1 = { { 0, 0XEAEAEA, 1 } } -- white
  local color2 = { { 0, 0XFFA300, 1 } } -- light orange
  local color3 = { { 0, 0xE7660B, 1 } } -- dark orange
  local color4 = { { 0, 0Xffe48f, 1 } } -- yellow
  local FONT = "Adele"

  text_settings = {

    {
      text = conky_parse("${time %H:%M}"),
      font_name = FONT,
      font_size = 72,
      h_align = "r",
      bold = false,
      x = 250,
      y = 80,
      reflection_alpha = 0.66,
      reflection_scale = 0.66,
      reflection_length = 1,    -- 0 to 1
      colour = color1,
    },
    {
      text = conky_parse("${time %d}"),
      font_name = FONT,
      font_size = 32,
      h_align = "l",
      bold = true,
      x = 260,
      y = 54,
      reflection_alpha = 0.66,
      reflection_scale = 0.66,
      reflection_length = 1,    -- 0 to 1
      colour = color3,
    },
    {
      text = conky_parse("${time %B %Y}"),
      font_name = FONT,
      font_size = 18,
      h_align = "l",
      bold = true,
      x = 308,
      y = 43,
      reflection_alpha = 0.66,
      reflection_scale = 0.66,
      reflection_length = 1,    -- 0 to 1
      colour = color4,
    },
    {
      text = conky_parse("${time %A}"),
      font_name = FONT,
      font_size = 48,
      h_align = "l",
      bold = false,
      x = 286,
      y = 80,
      reflection_alpha = 0.66,
      reflection_scale = 0.66,
      reflection_length = 1,    -- 0 to 1
      colour = color2,
    },

  }

  --------------END OF PARAMETERS----------------

  if conky_window == nil then
    return
  end
  if tonumber(conky_parse("$updates")) < 3 then
    return
  end

  local cs =
    cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

  for i, v in pairs(text_settings) do
    cr = cairo_create(cs)
    display_text(v)
    cairo_destroy(cr)
    cr = nil
  end

  cairo_surface_destroy(cs)
end

function rgb_to_r_g_b2(tcolour)
  local colour, alpha = tcolour[2], tcolour[3]
  return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function display_text(t)
  if t.draw_me == true then
    t.draw_me = nil
  end
  if t.draw_me ~= nil and conky_parse(tostring(t.draw_me)) ~= "1" then
    return
  end
  local function set_pattern(te)
    --this function set the pattern
    if #t.colour == 1 then
      cairo_set_source_rgba(cr, rgb_to_r_g_b2(t.colour[1]))
    else
      local pat

      if t.radial == nil then
        local pts = linear_orientation(t, te)
        pat = cairo_pattern_create_linear(pts[1], pts[2], pts[3], pts[4])
      else
        pat = cairo_pattern_create_radial(t.radial[1], t.radial[2], t.radial[3], t.radial[4], t.radial[5], t.radial[6])
      end

      for i = 1, #t.colour do
        cairo_pattern_add_color_stop_rgba(pat, t.colour[i][1], rgb_to_r_g_b2(t.colour[i]))
      end
      cairo_set_source(cr, pat)
      cairo_pattern_destroy(pat)
    end
  end

  --set default values if needed
  if t.text == nil then
    t.text = "Conky is good for you !"
  end
  if t.x == nil then
    t.x = conky_window.width / 2
  end
  if t.y == nil then
    t.y = conky_window.height / 2
  end
  if t.colour == nil then
    t.colour = { { 1, 0xE7660B, 1 } }
  end
  if t.font_name == nil then
    t.font_name = zekton
  end
  if t.font_size == nil then
    t.font_size = 14
  end
  if t.angle == nil then
    t.angle = 0
  end
  if t.italic == nil then
    t.italic = false
  end
  if t.oblique == nil then
    t.oblique = false
  end
  if t.bold == nil then
    t.bold = false
  end
  if t.radial ~= nil then
    if #t.radial ~= 6 then
      print("error in radial table")
      t.radial = nil
    end
  end
  if t.orientation == nil then
    t.orientation = "ww"
  end
  if t.h_align == nil then
    t.h_align = "l"
  end
  if t.v_align == nil then
    t.v_align = "b"
  end
  if t.reflection_alpha == nil then
    t.reflection_alpha = 0
  end
  if t.reflection_length == nil then
    t.reflection_length = 1
  end
  if t.reflection_scale == nil then
    t.reflection_scale = 1
  end
  if t.skew_x == nil then
    t.skew_x = 0
  end
  if t.skew_y == nil then
    t.skew_y = 0
  end
  cairo_translate(cr, t.x, t.y)
  cairo_rotate(cr, t.angle * math.pi / 180)
  cairo_save(cr)

  local slant = CAIRO_FONT_SLANT_NORMAL
  local weight = CAIRO_FONT_WEIGHT_NORMAL
  if t.italic then
    slant = CAIRO_FONT_SLANT_ITALIC
  end
  if t.oblique then
    slant = CAIRO_FONT_SLANT_OBLIQUE
  end
  if t.bold then
    weight = CAIRO_FONT_WEIGHT_BOLD
  end

  cairo_select_font_face(cr, t.font_name, slant, weight)

  for i = 1, #t.colour do
    if #t.colour[i] ~= 3 then
      print("error in color table")
      t.colour[i] = { 1, 0xFFFFFF, 1 }
    end
  end

  local matrix0 = cairo_matrix_t:create()
  tolua.takeownership(matrix0)
  local skew_x, skew_y = t.skew_x / t.font_size, t.skew_y / t.font_size
  cairo_matrix_init(matrix0, 1, skew_y, skew_x, 1, 0, 0)
  cairo_transform(cr, matrix0)
  cairo_set_font_size(cr, t.font_size)
  local te = cairo_text_extents_t:create()
  tolua.takeownership(te)
  t.text = conky_parse(t.text)
  cairo_text_extents(cr, t.text, te)
  set_pattern(te)

  local mx, my = 0, 0

  if t.h_align == "c" then
    mx = -te.width / 2 - te.x_bearing
  elseif t.h_align == "r" then
    mx = -te.width
  end
  if t.v_align == "m" then
    my = -te.height / 2 - te.y_bearing
  elseif t.v_align == "t" then
    my = -te.y_bearing
  end
  cairo_move_to(cr, mx, my)

  cairo_show_text(cr, t.text)

  if t.reflection_alpha ~= 0 then
    local matrix1 = cairo_matrix_t:create()
    tolua.takeownership(matrix1)
    cairo_set_font_size(cr, t.font_size)

    cairo_matrix_init(matrix1, 1, 0, 0, -1 * t.reflection_scale, 0, (te.height + te.y_bearing + my) * (1 + t.reflection_scale))
    cairo_set_font_size(cr, t.font_size)
    te = nil
    local te = cairo_text_extents_t:create()
    tolua.takeownership(te)
    cairo_text_extents(cr, t.text, te)

    cairo_transform(cr, matrix1)
    set_pattern(te)
    cairo_move_to(cr, mx, my)
    cairo_show_text(cr, t.text)

    local pat2 = cairo_pattern_create_linear(0, (te.y_bearing + te.height + my), 0, te.y_bearing + my)
    cairo_pattern_add_color_stop_rgba(pat2, 0, 1, 0, 0, 1 - t.reflection_alpha)
    cairo_pattern_add_color_stop_rgba(pat2, t.reflection_length, 0, 0, 0, 1)

    --line is not drawn but with a size of zero, the mask won't be nice
    cairo_set_line_width(cr, 1)
    local dy = te.x_bearing
    if dy < 0 then
      dy = dy * -1
    end
    cairo_rectangle(cr, mx + te.x_bearing, te.y_bearing + te.height + my, te.width + dy, -te.height * 1.05)
    cairo_clip_preserve(cr)
    cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR)
    --cairo_stroke(cr)
    cairo_mask(cr, pat2)
    cairo_pattern_destroy(pat2)
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER)
    te = nil
  end
end

function linear_orientation(t, te)
  local w, h = te.width, te.height
  local xb, yb = te.x_bearing, te.y_bearing

  if t.h_align == "c" then
    xb = xb - w / 2
  elseif t.h_align == "r" then
    xb = xb - w
  end
  if t.v_align == "m" then
    yb = -h / 2
  elseif t.v_align == "t" then
    yb = 0
  end
  local p = 0
  if t.orientation == "nn" then
    p = { xb + w / 2, yb, xb + w / 2, yb + h }
  elseif t.orientation == "ne" then
    p = { xb + w, yb, xb, yb + h }
  elseif t.orientation == "ww" then
    p = { xb, h / 2, xb + w, h / 2 }
  elseif vorientation == "se" then
    p = { xb + w, yb + h, xb, yb }
  elseif t.orientation == "ss" then
    p = { xb + w / 2, yb + h, xb + w / 2, yb }
  elseif t.orientation == "ee" then
    p = { xb + w, h / 2, xb, h / 2 }
  elseif t.orientation == "sw" then
    p = { xb, yb + h, xb + w, yb }
  elseif t.orientation == "nw" then
    p = { xb, yb, xb + w, yb + h }
  end
  return p
end
