local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

-- Font
theme.font          = "Montserrat 10"

-- Palette (neutral black + Catppuccin Blue accent)
theme.bg_normal     = "#161616"
theme.bg_focus      = "#262626"
theme.bg_urgent     = "#f38ba8"
theme.bg_minimize   = "#161616"
theme.bg_systray    = "#161616"

theme.fg_normal     = "#cdd6f4"
theme.fg_focus      = "#89b4fa"
theme.fg_urgent     = "#161616"
theme.fg_minimize   = "#6c7086"

theme.useless_gap   = dpi(6)
theme.border_width  = dpi(2)
theme.border_normal = "#262626"
theme.border_focus  = "#89b4fa"
theme.border_marked = "#f38ba8"

-- Wibar (bar) settings
theme.wibar_bg      = "#161616"
theme.wibar_fg      = "#cdd6f4"

-- Taglist
-- Taglist colors are handled entirely via widget_template in rc.lua
-- (numbers only, no background pills) — these are kept only as fallback.
theme.taglist_bg_focus    = "#161616"
theme.taglist_fg_focus    = "#FFFFFF"
theme.taglist_bg_occupied = "#161616"
theme.taglist_fg_occupied = "#A6ADC8"
theme.taglist_bg_empty    = "#161616"
theme.taglist_fg_empty    = "#4D4D4D"
theme.taglist_bg_urgent   = "#161616"
theme.taglist_fg_urgent   = "#f38ba8"
theme.taglist_spacing     = dpi(6)

-- Tasklist
theme.tasklist_bg_normal  = "#161616"
theme.tasklist_fg_normal  = "#cdd6f4"
theme.tasklist_bg_focus   = "#89b4fa"
theme.tasklist_fg_focus   = "#161616"

-- Notifications
theme.notification_bg = "#161616"
theme.notification_fg = "#cdd6f4"
theme.notification_border_color = "#89b4fa"
theme.notification_border_width = dpi(1)
theme.notification_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, 10)
end

-- Menu
theme.menu_height = dpi(30)
theme.menu_width  = dpi(160)
theme.menu_bg_normal = "#161616"
theme.menu_fg_normal = "#cdd6f4"
theme.menu_bg_focus  = "#89b4fa"
theme.menu_fg_focus  = "#161616"
theme.menu_border_color = "#262626"
theme.menu_border_width = dpi(1)

-- Icon theme
theme.icon_theme = nil

-- Generate icons (needed by taglist/menu)
theme.awesome_icon = theme_assets.awesome_icon(
    dpi(24), "#FFFFFF", theme.bg_normal
)

theme.layout_tile       = themes_path.."default/layouts/tile.png"
theme.layout_floating   = themes_path.."default/layouts/floating.png"
theme.layout_max        = themes_path.."default/layouts/max.png"
theme.layout_spiral     = themes_path.."default/layouts/spiral.png"
theme.layout_fairh      = themes_path.."default/layouts/fairh.png"
theme.layout_fairv      = themes_path.."default/layouts/fairv.png"

theme.wallpaper = "/home/quuixly/Pictures/city.jpg"

return theme
