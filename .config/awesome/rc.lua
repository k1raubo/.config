-- If LuaRocks is installed, load it
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- Freedesktop menu (Arch uses this)
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Startup error",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Error!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variables
-- Custom theme (neutral black + blue accent, rounded vertical wibar)
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme.lua")
beautiful.wallpaper = "/home/" .. os.getenv("USER") .. "/Pictures/city.jpg"
beautiful.useless_gap = 10

-- Colors used directly in this file (kept in sync with theme.lua)
local col_bg      = "#161616"
local col_bg_alt  = "#262626"
local col_fg      = "#cdd6f4"
local col_accent  = "#89b4fa"
local col_dim     = "#6c7086"

terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.fair,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.spiral,
}
-- }}}

-- {{{ Menu
local myawesomemenu = {
    { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Edit config", editor_cmd .. " " .. awesome.conffile },
    { "Restart", awesome.restart },
    { "Quit", function() awesome.quit() end },
}

local menu_awesome = { "Awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "Terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after = { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = { menu_awesome, menu_terminal }
    })
end

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

menubar.utils.terminal = terminal
-- }}}

-- {{{ Widgets
local mytextclock = wibox.widget.textclock("%H\n%M")
mytextclock.align = "center"
mytextclock.font = "Montserrat 15"

-- Icon font (Nerd Font needed only for glyphs like battery/wifi/bluetooth)
local icon_font = "JetBrainsMono Nerd Font 14"

-- {{{ Pomodoro timer (click the clock to open)
local pomodoro = {
    work_minutes = 25,
    break_minutes = 5,
    seconds_left = 25 * 60,
    on_break = false,
    running = false,
}

local pomodoro_time_label = wibox.widget {
    align = "center",
    valign = "center",
    font = "Montserrat 22",
    markup = "<span foreground='#FFFFFF'>25:00</span>",
    widget = wibox.widget.textbox,
}

local pomodoro_mode_label = wibox.widget {
    align = "center",
    valign = "center",
    font = "Montserrat 10",
    markup = "<span foreground='#6c7086'>WORK</span>",
    widget = wibox.widget.textbox,
}

local function pomodoro_button(label)
    local btn = wibox.widget {
        {
            {
                markup = "<span foreground='#CDD6F4'>" .. label .. "</span>",
                font = "Montserrat 10",
                align = "center",
                widget = wibox.widget.textbox,
            },
            margins = 8,
            widget = wibox.container.margin,
        },
        bg = "#262626",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 8) end,
        widget = wibox.container.background,
    }
    btn:connect_signal("mouse::enter", function() btn.bg = "#3A3A3A" end)
    btn:connect_signal("mouse::leave", function() btn.bg = "#262626" end)
    return btn
end

local pomodoro_start_btn = pomodoro_button("Start")
local pomodoro_reset_btn = pomodoro_button("Reset")

local pomodoro_popup = awful.popup {
    ontop = true,
    visible = false,
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 14) end,
    bg = "#161616",
    border_width = 1,
    border_color = "#262626",
    width = 180,
    widget = {
        {
            {
                pomodoro_mode_label,
                pomodoro_time_label,
                {
                    pomodoro_start_btn,
                    pomodoro_reset_btn,
                    spacing = 8,
                    layout = wibox.layout.flex.horizontal,
                },
                spacing = 10,
                layout = wibox.layout.fixed.vertical,
            },
            margins = 14,
            widget = wibox.container.margin,
        },
        layout = wibox.layout.fixed.vertical,
    },
}

local pomodoro_timer

local function pomodoro_update_display()
    local m = math.floor(pomodoro.seconds_left / 60)
    local s = pomodoro.seconds_left % 60
    pomodoro_time_label.markup =
        string.format("<span foreground='#FFFFFF'>%02d:%02d</span>", m, s)
    pomodoro_mode_label.markup = pomodoro.on_break
        and "<span foreground='#A6E3A1'>BREAK</span>"
        or "<span foreground='#6c7086'>WORK</span>"
end

local function pomodoro_tick()
    if not pomodoro.running then return end
    pomodoro.seconds_left = pomodoro.seconds_left - 1
    if pomodoro.seconds_left <= 0 then
        pomodoro.on_break = not pomodoro.on_break
        pomodoro.seconds_left = (pomodoro.on_break and pomodoro.break_minutes or pomodoro.work_minutes) * 60
        naughty.notify({
            title = pomodoro.on_break and "Time for a break!" or "Back to work!",
            text = pomodoro.on_break and "Rest for 5 minutes." or "25 minutes of focus.",
        })
    end
    pomodoro_update_display()
end

pomodoro_timer = gears.timer { timeout = 1, autostart = false, callback = pomodoro_tick }

pomodoro_start_btn:buttons(gears.table.join(
    awful.button({}, 1, function()
        pomodoro.running = not pomodoro.running
        if pomodoro.running then
            pomodoro_timer:start()
        else
            pomodoro_timer:stop()
        end
    end)
))

pomodoro_reset_btn:buttons(gears.table.join(
    awful.button({}, 1, function()
        pomodoro.running = false
        pomodoro.on_break = false
        pomodoro_timer:stop()
        pomodoro.seconds_left = pomodoro.work_minutes * 60
        pomodoro_update_display()
    end)
))

mytextclock:buttons(gears.table.join(
    awful.button({}, 1, function()
        if pomodoro_popup.visible then
            pomodoro_popup.visible = false
        else
            local s = screen.primary or awful.screen.focused()
            if s and s.mywibox then
                pomodoro_popup.x = s.mywibox.x + s.mywibox.width + 10
                local popup_h = pomodoro_popup.height or 160
                local bar_bottom = s.mywibox.y + s.mywibox.height
                pomodoro_popup.y = bar_bottom - popup_h
            end
            pomodoro_popup.visible = true
        end
    end)
))
-- }}}

-- Battery widget (vertical icon, color depends on charge level; percentage shown as tooltip on hover)
-- IMPORTANT: font is set directly on the textbox widget (not just inside the
-- markup span). Setting it only in markup caused Awesome's layout engine to
-- miscalculate the glyph's natural size, clipping it. Also: no forced_width/
-- height on the container - let it size naturally and just center it.
local battery_txt = wibox.widget {
    align = "center",
    valign = "center",
    font = icon_font,
    widget = wibox.widget.textbox,
}
local battery_widget = wibox.widget {
    battery_txt,
    forced_width = 54,
    forced_height = 30,
    widget = wibox.container.place,
}

local battery_tooltip = awful.tooltip {
    objects = { battery_widget },
    mode = "outside",
    preferred_positions = { "right" },
    margin_leftright = 8,
    margin_topbottom = 4,
    bg = "#161616",
    fg = "#FFFFFF",
    border_width = 1,
    border_color = "#262626",
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 8) end,
}

local function update_battery()
    local cmd = "upower -i `upower -e | grep BAT` | grep -E 'percentage|state' | awk '{print $2}'"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
        local lines = {}
        for line in stdout:gmatch('[^\r\n]+') do table.insert(lines, line) end

        local state = lines[1] or ""
        local percent = lines[2] or ""
        local percent_num = tonumber(percent:match("%d+")) or 100

        -- mdi-battery (vertical, confirmed codepoint F0079) / mdi-battery-charging (F0084)
        local icon = (state == "charging") and "\u{f0084}" or "\u{f0079}"

        local color
        if percent_num < 20 then
            color = "#f38ba8" -- red
        elseif percent_num < 50 then
            color = "#f9e2af" -- yellow
        else
            color = "#a6e3a1" -- green
        end

        battery_txt.markup = "<span foreground='" .. color .. "'>" .. icon .. "</span>"
        battery_tooltip:set_text(percent ~= "" and percent or "?%")
    end)
end

gears.timer {
    timeout = 10,
    autostart = true,
    call_now = true,
    callback = update_battery
}

-- Wifi widget (white icon, placeholder only)
local wifi_txt = wibox.widget {
    align = "center",
    valign = "center",
    font = icon_font,
    widget = wibox.widget.textbox,
}
local wifi_widget = wibox.widget {
    wifi_txt,
    forced_width = 54,
    forced_height = 30,
    widget = wibox.container.place,
}

local function update_wifi()
    awful.spawn.easy_async_with_shell(
        "nmcli -t -f WIFI g 2>/dev/null",
        function(stdout)
            local on = stdout:match("enabled")
            local color = on and "#FFFFFF" or "#4D4D4D"
            wifi_txt.markup = "<span foreground='" .. color .. "'>\u{f1eb}</span>" -- fa-wifi
        end
    )
end

gears.timer {
    timeout = 15,
    autostart = true,
    call_now = true,
    callback = update_wifi
}

-- Bluetooth widget (white icon, placeholder only)
local bluetooth_txt = wibox.widget {
    align = "center",
    valign = "center",
    font = icon_font,
    widget = wibox.widget.textbox,
}
local bluetooth_widget = wibox.widget {
    bluetooth_txt,
    forced_width = 54,
    forced_height = 30,
    widget = wibox.container.place,
}

local function update_bluetooth()
    awful.spawn.easy_async_with_shell(
        "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo on || echo off",
        function(stdout)
            local on = stdout:match("on")
            local color = on and "#FFFFFF" or "#4D4D4D"
            bluetooth_txt.markup = "<span foreground='" .. color .. "'>\u{f293}</span>" -- fa-bluetooth
        end
    )
end

gears.timer {
    timeout = 15,
    autostart = true,
    call_now = true,
    callback = update_bluetooth
}

-- }}}

-- {{{ Screen setup
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t)
        for s in screen do
            local target_tag = s.tags[t.index]
            if target_tag then
                target_tag:view_only()
            end
        end
    end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
        end
    end)
)

local function set_wallpaper(s)
    if beautiful.wallpaper then
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

local function focus_or_screen(dir)
    return function()
        local c = client.focus
        if c then
            awful.client.focus.bydirection(dir)
            if client.focus == c then
                awful.screen.focus_bydirection(dir)
            end
        else
            awful.screen.focus_bydirection(dir)
        end
    end
end

local function move_or_screen(dir)
    return function()
        local c = client.focus
        if not c then return end

        local before_tags = c.first_tag

        awful.client.swap.bydirection(dir)

        if c.first_tag == before_tags then
            local target_screen = c.screen:get_next_in_direction(dir)
            if target_screen then
                c:move_to_screen(target_screen)
                c:raise()
                client.focus = c
            end
        end
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    awful.tag({ "1","2","3","4","5","6","7","8","9" }, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()

    -- Vertical taglist, plain numbers only (no pill background)
    -- empty tag  = dim gray
    -- tag with a client (but not selected) = light gray
    -- selected/active tag = white
    if s == screen.primary then
        s.mytaglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = taglist_buttons,
            layout = {
                spacing = 6,
                layout = wibox.layout.fixed.vertical,
            },
            widget_template = {
                {
                    id     = "text_role",
                    align  = "center",
                    valign = "center",
                    font   = "Montserrat 10",
                    widget = wibox.widget.textbox,
                },
                id              = "background_role",
                forced_width    = 30,
                forced_height   = 20,
                bg              = "#00000000",
                widget          = wibox.container.background,
                create_callback = function(self, t, index, objects)
                    self.bg = "#00000000"
                    local text_widget = self:get_children_by_id("text_role")[1]
                    if t.selected then
                        text_widget.markup = "<span foreground='#FFFFFF'>" .. t.name .. "</span>"
                    elseif #t:clients() > 0 then
                        text_widget.markup = "<span foreground='#A6ADC8'>" .. t.name .. "</span>"
                    else
                        text_widget.markup = "<span foreground='#4D4D4D'>" .. t.name .. "</span>"
                    end
                end,
                update_callback = function(self, t, index, objects)
                    self.bg = "#00000000"
                    local text_widget = self:get_children_by_id("text_role")[1]
                    if t.selected then
                        text_widget.markup = "<span foreground='#FFFFFF'>" .. t.name .. "</span>"
                    elseif #t:clients() > 0 then
                        text_widget.markup = "<span foreground='#A6ADC8'>" .. t.name .. "</span>"
                    else
                        text_widget.markup = "<span foreground='#4D4D4D'>" .. t.name .. "</span>"
                    end
                end,
            },
        }

        s.mytasklist = awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons,
            layout = {
                spacing = 6,
                layout = wibox.layout.fixed.vertical,
            },
        }

        -- Vertical, floating, rounded wibar (island style, like the screenshot)
        -- Height matches the same gap used for tiled windows, so the bar's top/bottom
        -- edges line up with where windows actually start/end.
        -- Vertical margin between the bar and the top/bottom screen edges.
        local wibar_vmargin = 16

        s.mywibox = awful.wibar({
            position = "left",
            screen = s,
            width = 54,
            height = s.workarea.height - (wibar_vmargin * 2),
            bg = col_bg,
            fg = col_fg,
            shape = function(cr, w, h)
                gears.shape.rounded_rect(cr, w, h, 20)
            end,
        })

        -- IMPORTANT: position="left" auto-docks the wibar to x=0, overriding any
        -- x/y passed in the constructor above. We must set x/y explicitly AFTER
        -- creation for the floating "island" offset to actually stick.
        s.mywibox.x = 16
        s.mywibox.y = s.workarea.y + wibar_vmargin

        -- The strut (reserved space so windows don't overlap the bar) is computed
        -- from the bar's geometry at creation time (x=0). Since we moved it,
        -- we must recompute the strut manually or windows will render underneath
        -- part of the bar / leave a dead gap.
        s.mywibox:struts({ left = s.mywibox.x + s.mywibox.width })

        -- White AwesomeWM logo button (opens the main menu)
        local menu_button = wibox.widget {
            {
                image = beautiful.awesome_icon,
                forced_width = 22,
                forced_height = 22,
                widget = wibox.widget.imagebox,
            },
            widget = wibox.container.place,
        }
        menu_button:buttons(gears.table.join(
            awful.button({}, 1, function() mymainmenu:toggle() end)
        ))

        s.mywibox:setup {
            layout = wibox.layout.align.vertical,
            expand = "none",
            {
                layout = wibox.layout.fixed.vertical,
                spacing = 10,
                {
                    menu_button,
                    left = 8, right = 8, top = 20, bottom = 8,
                    widget = wibox.container.margin,
                },
                {
                    s.mytaglist,
                    margins = 4,
                    widget = wibox.container.margin,
                },
            },
            nil,
            {
                layout = wibox.layout.fixed.vertical,
                spacing = 10,
                {
                    bluetooth_widget,
                    top = 4, bottom = 4,
                    widget = wibox.container.margin,
                },
                {
                    wifi_widget,
                    top = 4, bottom = 4,
                    widget = wibox.container.margin,
                },
                {
                    battery_widget,
                    top = 4, bottom = 4,
                    widget = wibox.container.margin,
                },
                {
                    mytextclock,
                    left = 8, right = 8, top = 8, bottom = 20,
                    widget = wibox.container.margin,
                },
            },
        }

        -- keep the wibar geometry correct if the screen geometry changes
        s:connect_signal("property::geometry", function()
            s.mywibox.height = s.workarea.height - (wibar_vmargin * 2)
            s.mywibox.x = 16
            s.mywibox.y = s.workarea.y + wibar_vmargin
            s.mywibox:struts({ left = s.mywibox.x + s.mywibox.width })
        end)
    end
end)
-- }}}

-- {{{ Mouse
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end)
))
-- }}}

-- {{{ Keybindings
globalkeys = gears.table.join(
    awful.key({ modkey }, "t", function() awful.spawn(terminal) end,
        { description = "Open terminal", group = "launcher" }),

    awful.key({ modkey }, "f", function() awful.spawn("firefox") end,
        { description = "Open Firefox", group = "launcher" }),

    awful.key({ modkey }, "e", function() awful.spawn("nemo") end,
        { description = "Open file manager", group = "launcher" }),

    awful.key({ modkey }, "r", function() awful.spawn("rofi -show drun")  end,
        { description = "Run prompt", group = "launcher" }),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "Restart Awesome", group = "awesome" }),

    awful.key({ modkey, "Shift" }, "s", function() awesome.spawn("ksnip -r -c") end,
        { description = "Make screenshot", group = "awesome" }),

    awful.key({ modkey }, "space", function() awful.layout.inc(1) end,
        { description = "next layout", group = "layout" }),

    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "previous layout", group = "layout" }),

    awful.key({ modkey }, "q",
        function()
            if client.focus then
                client.focus:kill()
            end
        end,
        { description = "close focused window", group = "client" }),

    awful.key({}, "XF86AudioRaiseVolume",
        function()
            awful.spawn("pamixer --increase 5")
        end,
        { description = "volume up", group = "audio" }),

    awful.key({}, "XF86AudioLowerVolume",
        function()
            awful.spawn("pamixer --decrease 5")
        end,
        { description = "volume down", group = "audio" }),

    awful.key({}, "XF86AudioMute",
        function()
            awful.spawn("pamixer --toggle-mute")
        end,
        { description = "toggle mute", group = "audio" }),

    -- Brightness up
    awful.key({ }, "XF86MonBrightnessUp",
        function()
            awful.spawn("brightnessctl set +5%", false)
        end,
        {description = "brightness up", group = "brightness"}),

    -- Brightness down
    awful.key({ }, "XF86MonBrightnessDown",
        function()
            awful.spawn("brightnessctl set 5%-", false)
        end,
        {description = "brightness down", group = "brightness"}),

    -- Focus windows with Win + Arrow keys
    awful.key({ modkey }, "Left",  focus_or_screen("left"),
        { description = "focus left / screen", group = "client" }),
    awful.key({ modkey }, "Right", focus_or_screen("right"),
        { description = "focus right / screen", group = "client" }),
    awful.key({ modkey }, "Up",    focus_or_screen("up"),
        { description = "focus up / screen", group = "client" }),
    awful.key({ modkey }, "Down",  focus_or_screen("down"),
        { description = "focus down / screen", group = "client" }),

    awful.key({ modkey, "Shift" }, "Left",  move_or_screen("left"),
        { description = "move window left / to left screen", group = "client" }),
    awful.key({ modkey, "Shift" }, "Right", move_or_screen("right"),
        { description = "move window right / to right screen", group = "client" }),
    awful.key({ modkey, "Shift" }, "Up",    move_or_screen("up"),
        { description = "move window up / to top screen", group = "client" }),
    awful.key({ modkey, "Shift" }, "Down",  move_or_screen("down"),
        { description = "move window down / to bottom screen", group = "client" })
)

root.keys(globalkeys)
-- }}}

-- Windows switching
-- Tag navigation: Mod + number to view tag, Mod+Shift+number to move client
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,

        -- View tag simultaneously on all screens
        awful.key({ modkey }, "#" .. i + 9,
                  function()
                        for s in screen do
                            local tag = s.tags[i]
                            if tag then
                                tag:view_only()
                            end
                        end
                  end,
                  {description = "view tag #"..i.." on all screens", group = "tag"}),

        -- Move focused client to tag
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                      end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
    )
end

-- reapply the keys
root.keys(globalkeys)


-- {{{ Rules
awful.rules.rules = {
    {
        rule = { },
        properties = {
            border_width = 3,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    }
}
-- }}}

-- {{{ Signals
client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
-- }}}

-- Enable touchpad tapping (optional)
awful.spawn.with_shell('xinput set-prop 12 "libinput Tapping Enabled" 1')

awful.spawn.with_shell('xinput set-prop 11 "libinput Tapping Enabled" 1')

-- Picom
awful.spawn.with_shell("picom --config ~/.config/picom/picom.conf &")

-- Resolution
awful.spawn.with_shell([[
bash -c '
    monitors=($(xrandr -q | grep " connected" | awk "{print \$1}"))
    cmd="xrandr"
    prev=""
    for i in "${!monitors[@]}"; do
        m="${monitors[$i]}"
        if [ $i -eq 0 ]; then
            cmd="$cmd --output $m --primary --mode 1920x1080 --auto"
        else
            cmd="$cmd --output $m --mode 1920x1080 --auto --right-of $prev"
        fi
        prev="$m"
    done
    eval "$cmd"
'
]])
