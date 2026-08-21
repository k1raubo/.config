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
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper = "/home/kraubo/Pictures/mountain.jpg"
beautiful.useless_gap = "10"
terminal = "alacritty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.spiral,
    awful.layout.suit.fair,
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
local mykeyboardlayout = awful.widget.keyboardlayout()
local mytextclock = wibox.widget.textclock("%H:%M  %a %d %b")
mytextclock.font = "sans 11"
-- }}}
-- {{{ Screen setup
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
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
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
    awful.tag({ "1","2","3","4","5","6","7","8","9" }, s, awful.layout.layouts[1])
    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end)
    ))
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }
    s.mywibox = awful.wibar({
        position = "top",
        screen = s,
        height = 32,
        bg = "#1a1a1aee",
        fg = "#eeeeee"
    })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = 8,
            wibox.container.margin(mylauncher, 6, 4, 4, 4),
            wibox.container.margin(s.mytaglist, 4, 4, 4, 4),
            s.mypromptbox,
        },
        nil,
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = 12,
            wibox.widget.systray(),
            wibox.container.margin(mytextclock, 4, 10, 6, 6),
        }
    }
end)
-- }}}
-- {{{ Mouse
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end)
))
-- }}}
-- {{{ Keybindings
globalkeys = gears.table.join(
    awful.key({ modkey, "Shift" }, "p", function() awesome.quit() end,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "Restart Awesome", group = "awesome" }),
    awful.key({ modkey }, "t", function() awful.spawn(terminal) end,
        { description = "Open terminal", group = "launcher" }),
    awful.key({ modkey }, "f", function() awful.spawn("firefox") end,
        { description = "Open Firefox", group = "launcher" }),
    awful.key({ modkey }, "e", function() awful.spawn("nemo") end,
        { description = "Open file manager", group = "launcher" }),
    awful.key({ modkey }, "r", function() awful.spawn("rofi -show drun")  end,
        { description = "Run prompt", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "s", function() awesome.spawn("ksnip -r") end,
        { description = "Restart Awesome", group = "awesome" }),
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
    -- Focus windows with Win + Arrow keys (crosses monitors)
    awful.key({ modkey }, "Left",
        function()
            local c = awful.client.focus.global_bydirection and awful.client.focus.global_bydirection("left")
            if not client.focus then
                awful.screen.focus_bydirection("left")
            end
        end,
        { description = "focus left", group = "client" }),
    awful.key({ modkey }, "Right",
        function()
            awful.client.focus.global_bydirection("right")
            if not client.focus then
                awful.screen.focus_bydirection("right")
            end
        end,
        { description = "focus right", group = "client" }),
    awful.key({ modkey }, "Up",
        function()
            awful.client.focus.global_bydirection("up")
            if not client.focus then
                awful.screen.focus_bydirection("up")
            end
        end,
        { description = "focus up", group = "client" }),
    awful.key({ modkey }, "Down",
        function()
            awful.client.focus.global_bydirection("down")
            if not client.focus then
                awful.screen.focus_bydirection("down")
            end
        end,
        { description = "focus down", group = "client" }),
    -- Switch focused monitor directly (Mod+Ctrl+Arrow)
    awful.key({ modkey, "Control" }, "Left", function() awful.screen.focus_bydirection("left") end,
        { description = "focus screen left", group = "screen" }),
    awful.key({ modkey, "Control" }, "Right", function() awful.screen.focus_bydirection("right") end,
        { description = "focus screen right", group = "screen" }),
    -- Move focused window to the other/adjacent monitor (keeps its tag index, follows focus)
    awful.key({ modkey, "Shift" }, "o",
        function()
            if client.focus then
                local c = client.focus
                local s = c.screen.index == 1 and screen[2] or screen[1]
                if s then
                    c:move_to_screen(s)
                    client.focus = c
                end
            end
        end,
        { description = "move client to other screen", group = "client" }),
    awful.key({ modkey, "Shift" }, "Left",
        function()
            if client.focus then
                local c = client.focus
                c:move_to_screen(c.screen.index > 1 and c.screen.index - 1 or screen.count())
                client.focus = c
            end
        end,
        { description = "move client to screen left", group = "client" }),
    awful.key({ modkey, "Shift" }, "Right",
        function()
            if client.focus then
                local c = client.focus
                c:move_to_screen(c.screen.index < screen.count() and c.screen.index + 1 or 1)
                client.focus = c
            end
        end,
        { description = "move client to screen right", group = "client" })
)
root.keys(globalkeys)
-- }}}
-- Windows switching
-- Tag navigation: Mod + number to view tag, Mod+Shift+number to move client
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only
        awful.key({ modkey }, "#" .. i + 9,
                  function()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
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
            border_color = "#444444",
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
    c.border_color = "#3b82f6"
    c.border_width = 4
end)
client.connect_signal("unfocus", function(c)
    c.border_color = "#444444"
    c.border_width = 3
end)
-- Focus follows mouse (doesn't raise, just switches focus)
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)
-- }}}
-- Enable touchpad tapping (optional)
awful.spawn.with_shell('xinput set-prop 12 "libinput Tapping Enabled" 1')
awful.spawn.with_shell('xinput set-prop 11 "libinput Tapping Enabled" 1')
