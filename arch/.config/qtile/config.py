############################
# QTILE CONFIGURATION FILE #
#
# Autor: Gabriel Nascimento - 2022
# http://www.github.com/gnsbriel
#

# Section: ----- Imports -----

import os
import subprocess
from functions import Functions
from libqtile import bar, hook, layout, qtile, widget
from libqtile.command import lazy
from libqtile.config import (Click, Drag, DropDown, Group, Key, Match,
                             ScratchPad, Screen)
from libqtile.lazy import lazy
from settings.applications import Apps
from settings.colors import colors, icons

# Section: ----- Qtile Configurations -----

auto_fullscreen = False
bring_front_click = "floating_only"
cursor_warp = False
follow_mouse_focus = False
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = False
wmname = "LG3D"

# Section: ----- Qtile Windows Layouts -----

# Floating Layout
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,  # Default Rules;
        Match(wm_class="confirmreset"),        # gitk;
        Match(wm_class="makebranch"),          # gitk;
        Match(wm_class="maketag"),             # gitk;
        Match(wm_class="ssh-askpass"),         # ssh-askpass;
        Match(wm_class="VirtualBox Machine"),  # Virtual Box;
        Match(wm_class="piper"),               # Piper;
        Match(wm_class="galculator"),          # Galculator;
        Match(title="branchdialog"),           # gitk;
        Match(title="pinentry")                # GPG key password entry;
    ],
    border_focus=colors["09"],   # Focused Floating Window - Boder Color;
    border_normal=colors["09"],  # Unfocused Floating Window - Border Color;
    border_width=1,              # Border Width;
    fullscreen_border_width=0,   # Border Width When in Fullscreen;
    max_border_width=0           # Maximum Border Width;
)

# Default Layout Settings
layout_defaults = {
    "border_focus": colors["02"],   # Focused Window - Border Color;
    "border_normal": colors["00"],  # Unfocused Window - Border Color;
    "border_width": 2,              # Border Width;
    "margin": 5                     # Margin (Gap);
}

# Layout List
layouts = [
    layout.MonadTall(
        **layout_defaults,
        ratio=0.56,
        max_ratio=0.85,
        min_ratio=0.15,
        min_secondary_size=85,
        change_ratio=0.01,
        change_size=20,
        new_client_position="bottom",
        single_border_width=0,
        single_margin=5
    )
]

# Section: ----- Qtile Groups -----


# Workspaces
groups = [
    Group(
        name="1",
        label="󰖟",
        layout="monadtall"
    ),
    Group(
        name="2",
        label="󰆍",
        layout="monadtall"
    ),
    Group(
        name="3",
        label="󰉖",
        layout="MonadTall"
    ),
    Group(
        name="4",
        label="󰓇",
        layout="MonadTall"
    ),
    Group(
        name="5",
        label="󰓓",
        layout="MonadTall",
        matches=[
            Match(wm_class="Steam")
        ]
    ),
    Group(
        name="6",
        label="󰍺",
        layout="MonadTall",
        matches=[
            Match(wm_class="VirtualBox Manager"),
            Match(wm_class="VirtualBox Machine")
        ]
    ),
    Group(
        name="9",
        label="󰢹",
        layout="MonadTall",
        matches=[
            Match(wm_class="xfreerdp")
        ],
        init=False,
        persist=False
    )
]

# Section: ----- Qtile Keybindings -----

# Mod
mod = "mod4"

# Keybindings
keys = [Key(key[0], key[1], *key[2:]) for key in [

    # ----- Window ----- #

    # Change focus
    ([mod], "i", lazy.layout.up()),
    ([mod], "j", lazy.layout.left()),
    ([mod], "k", lazy.layout.down()),
    ([mod], "l", lazy.layout.right()),

    # Move window
    ([mod, "shift"], "i", lazy.layout.shuffle_up()),
    ([mod, "shift"], "j", lazy.layout.swap_left()),
    ([mod, "shift"], "k", lazy.layout.shuffle_down()),
    ([mod, "shift"], "l", lazy.layout.swap_right()),

    # Resize window
    ([mod, "control"], "i", lazy.layout.grow()),
    ([mod, "control"], "j", lazy.layout.shrink_main()),
    ([mod, "control"], "k", lazy.layout.shrink()),
    ([mod, "control"], "l", lazy.layout.grow_main()),
    ([mod, "control"], "space", lazy.layout.reset()),

    # Kill focused window
    ([mod, "control"], "c", lazy.window.kill()),

    # ----- Layouts ----- #

    # Floating
    ([mod], "v", lazy.window.toggle_floating()),

    # Fullscreen
    ([mod, "control"], "f", lazy.window.toggle_fullscreen()),

    # Minimize
    ([mod], "c", lazy.window.toggle_minimize()),

    # MonadTall
    ([mod], "space", lazy.layout.flip()),
    ([mod], "f", lazy.layout.maximize()),

    # ----- Qtile ----- #

    # Config file
    ([mod], "BackSpace", lazy.reload_config()),

    # System
    ([mod, "control"], "BackSpace", lazy.restart()),
    ([mod, "control"], "Delete", lazy.shutdown()),

    # Lockscreen
    ([mod], "Delete", lazy.spawn("slock")),

    # Terminal
    ([mod], "Return", lazy.spawn(Apps.terminal)),

    # Rofi
    ([mod], "r", lazy.spawn(Apps.drun)),
    ([mod], "period", lazy.spawn(Apps.emojiSelector)),

    # Xkill
    ([mod, "shift"], "c", lazy.spawn("xkill")),

    # Change Wallpaper
    ([mod], "b", lazy.spawn("changebg")),

    # ----- Workspace ----- #

    # Change workspace
    ([mod], "Tab", lazy.screen.next_group()),
    ([mod, "shift"], "Tab", lazy.screen.prev_group()),

    # ----- Applications ----- #

    # Multimedia Keys
    ([], "XF86Explorer", lazy.spawn("thunar")),
    ([], "XF86HomePage", Functions.minimize_all()),
    ([], "XF86Mail", lazy.spawn("thunderbird")),
    ([], "XF86Calculator", lazy.spawn("galculator")),
    ([], "XF86Tools", lazy.spawn("qtile run-cmd -g 4 spotify")),
    ([], "XF86AudioStop", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause")),      # noqa E501
    ([], "XF86AudioPrev", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")),   # noqa E501
    ([], "XF86AudioPlay", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")),  # noqa E501
    ([], "XF86AudioNext", lazy.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")),       # noqa E501
    ([], "XF86AudioMute", lazy.spawn("pulsemixer --toggle-mute")),
    ([], "XF86AudioLowerVolume", lazy.spawn("changeVolume -1")),
    ([], "XF86AudioRaiseVolume", lazy.spawn("changeVolume +1")),

    # Applications
    ([mod], "q", lazy.spawn("firefox")),
    ([mod], "w", lazy.spawn("code")),
    ([mod], "e", lazy.spawn("thunar")),
    ([mod], "s", lazy.spawn("steam"))
]]

# Group Keybindings
for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.group[i.name].toscreen(),
            desc="Switch to group {}".format(i.name)),
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True),  # noqa E501
            desc="Move focused window to group {}".format(i.name)),
        Key([mod, "control"], i.name, lazy.window.togroup(i.name),
            desc="move focused window to group {}".format(i.name)),
    ])

# Mouse Keybindings
mouse = [
    Drag([mod], "Button1",
                lazy.window.set_position_floating(),
                start=lazy.window.get_position()),
    Drag([mod], "Button3",
                lazy.window.set_size_floating(),
                start=lazy.window.get_size()),
    Click([mod], "Button2",
                 lazy.window.bring_to_front()),
]

# Section: ----- Qtile Scratchpads -----

# Scratchpads
groups.append(
    ScratchPad("scratchpad", [
        DropDown("term", Apps.terminal, height=0.5,
                 width=0.5, x=0.25, y=0.25, opacity=1.0),
        DropDown("audiomixer", Apps.terminal + " -e 'pulsemixer'",
                 height=0.5, width=0.5, x=0.25, y=0.25, opacity=1.0),
        DropDown("rdp", Apps.terminal + " -e 'runrdp'",
                 height=0.5, width=0.5, x=0.25, y=0.25, opacity=1.0),
        DropDown("email", 'thunderbird',
                 height=0.95, width=0.95, x=0.025, y=0.025, opacity=1.0)
        ]),
    )

# Scratchpad Keybindings
keys.extend([
    Key([mod], 't', lazy.group['scratchpad'].dropdown_toggle('term')),
    Key([mod], 'g', lazy.group['scratchpad'].dropdown_toggle('audiomixer')),
    Key([mod], 'd', lazy.group['scratchpad'].dropdown_toggle('rdp')),
    Key([], 'XF86Mail', lazy.group['scratchpad'].dropdown_toggle('email'))
])

# Section: ----- Qtile Widgets -----

# Default Widget Settings
widget_defaults = dict(
    background=colors["00"],
    foreground=colors["01"],
    font="Hack NF Bold",
    fontsize=12,
    padding=0
)
extension_defaults = widget_defaults.copy()

qtile_bar_icons = {
    "font": "Material Design Icons Desktop",
    "background": colors["00"],
    "fontsize": 18,
    "padding": 0
}

qtile_bar_sep = {
    "padding": 20,
    "foreground": colors["00"]
}

# Section: ----- Qtile Screens -----

screens = [
    # Screen 1
    Screen(top=bar.Bar([
        widget.Sep(
            padding=8,
            foreground=colors["09"],
            background=colors["09"],
            mouse_callbacks={"Button1": lazy.spawn(Apps.drun)}
        ),
        widget.TextBox(
            font="Material Design Icons Desktop",
            background=colors["09"],
            fontsize=18,
            foreground=colors["05"],
            text=icons["arch"],
            mouse_callbacks={"Button1": lazy.spawn(Apps.drun)}
        ),
        widget.TextBox(
            foreground=colors["09"],
            fontsize=32,
            text="",
            mouse_callbacks={"Button1": lazy.spawn(Apps.drun)}
        ),
        widget.GroupBox(
            font="Material Design Icons Desktop",
            active=colors["08"],
            inactive=colors["09"],
            block_highlight_text_color=colors["08"],
            urgent_border=colors["10"],
            urgent_text=colors["10"],
            highlight_color=[colors['00'], colors['14']],
            this_current_screen_border=colors["14"],
            highlight_method="line",
            urgent_alert_method="line",
            borderwidth=3,
            rounded=True,
            center_aligned=True,
            invert_mouse_wheel=True,
            disable_drag=True,
            fontsize=18,
            margin=3,
            padding=4
        ),
        widget.Sep(
            padding=5,
            foreground=colors["00"],
            background=colors["00"]
        ),
        widget.TaskList(
            markup=True,
            foreground=colors["08"],
            border=colors["02"],
            unfocused_border=colors["09"],
            urgent_border=colors["06"],
            highlight_method="block",
            markup_focused="<span font='Hack NF Bold 9'> {}</span>",
            markup_normal="<span font='Hack NF Bold 9'> {}</span>",
            markup_floating="<span font='Hack NF Bold 9'> [F] {}</span>",
            markup_minimized="<span font='Hack NF Bold 9'> [-] {}</span>",
            markup_maximized="<span font='Hack NF Bold 9'> [+] {}</span>",
            borderwidth=1,
            icon_size=0,
            margin_x=3,
            margin_y=3,
            max_title_width=128,
            padding_x=3,
            padding_y=3,
            rounded=True,
            spacing=10,
            title_width_method="uniform",
            urgent_alert_method="text",
        ),
        widget.Sep(
            **qtile_bar_sep
        ),
        widget.TextBox(
            **qtile_bar_icons,
            foreground=colors["02"],
            text=icons["upda"],
            mouse_callbacks={"Button1": lazy.spawn(
                Apps.terminal + " -e sudo pacman -Syyu")}
        ),
        widget.CheckUpdates(
            markup=True,
            colour_have_updates=colors["02"],
            colour_no_updates=colors["02"],
            no_update_string="""<span font='Hack NF Bold 9' underline='double'
                             underline_color='#ff616e'>No Updates</span>""",
            distro="Arch",
            display_format="""<span font='Hack NF Bold 9' underline='double'
                           underline_color='#ff616e'
                           >There are {updates} Updates</span>""",
            mouse_callbacks={"Button1": lazy.spawn(
                Apps.terminal + " -e sudo pacman -Syyu &")}
        ),
        widget.Sep(
            **qtile_bar_sep
        ),
        widget.TextBox(
            **qtile_bar_icons,
            foreground=colors["08"],
            text=icons["cpu"],
            mouse_callbacks={"Button1": lazy.spawn(
                Apps.terminal + " -e btop")}
        ),
        widget.CPU(
            markup=True,
            format="""<span font='Hack NF Bold 9' underline='double'
                   underline_color='#e6e6e6'>CPU {load_percent}%</span>""",
            update_interval=1,
            foreground=colors["08"],
            mouse_callbacks={"Button1": lazy.spawn(
                Apps.terminal + " -e btop")}
        ),
        widget.Sep(
            **qtile_bar_sep
        ),
        widget.TextBox(
            **qtile_bar_icons,
            foreground=colors["05"],
            text=icons["temp"]
        ),
        widget.ThermalSensor(
            markup=True,
            foreground=colors["05"],
            fmt="""<span font='Hack NF Bold 9' underline='double'
                underline_color='#4dc4ff'>CPU {}</span>""",
            threshold=90,
            tag_sensor="Package id 0",
            update_interval=1
        ),
        widget.Sep(
            **qtile_bar_sep
        ),
        widget.TextBox(
            **qtile_bar_icons,
            foreground=colors["05"],
            text=icons["temp"]
        ),
        widget.ThermalSensor(
            markup=True,
            foreground=colors["05"],
            fmt="""<span font='Hack NF Bold 9' underline='double'
                underline_color='#4dc4ff'>GPU {}</span>""",
            tag_sensor="edge",
            threshold=90,
            update_interval=1
        ),
        widget.Sep(
            **qtile_bar_sep
        ),
        widget.TextBox(
            **qtile_bar_icons,
            foreground=colors["06"],
            text=icons["mem"],
            mouse_callbacks={"Button1": lazy.spawn(
                Apps.terminal + " -e htop")}
        ),
        widget.Memory(
            markup=True,
            format="""<span font='Hack NF Bold 9' underline='double'
                   underline_color='#de73ff'
                   >RAM {MemUsed:.0f}{mm}/{MemTotal:.0f}{mm}</span>""",
            foreground=colors["06"],
            measure_mem="M",
            mouse_callbacks={"Button1": lazy.spawn(
                Apps.terminal + " -e htop")}
        ),
        widget.Sep(
            **qtile_bar_sep
        ),
        widget.TextBox(
            **qtile_bar_icons,
            foreground=colors["03"],
            text=icons["pom"]
        ),
        widget.Pomodoro(
            markup=True,
            color_active=colors["03"],
            color_inactive=colors["03"],
            color_break=colors["03"],
            fmt="""<span font='Hack NF Bold 9' underline='double'
                underline_color='#a5e075'>{}</span>""",
            prefix_active="""<span font='Hack NF Bold 9' underline='double'
                          underline_color='#a5e075'></span>""",
            prefix_inactive="""<span font='Hack NF Bold 9' underline='double'
                            underline_color='#a5e075'>25min</span>""",
            prefix_break="""<span font='Hack NF Bold 9' underline='double'
                         underline_color='#a5e075'>Short Break ! </span>""",
            prefix_long_break="""<span font='Hack NF Bold 9' underline='double'
                              underline_color='#a5e075'
                              >Take a Break ! </span>""",
            prefix_paused="""<span font='Hack NF Bold 9' underline='double'
                          underline_color='#a5e075'>PAUSE</span>""",
            num_pomodori=4,
            length_pomodori=25,
            length_short_break=5,
            length_long_break=15,
        ),
        widget.Sep(
            **qtile_bar_sep
        ),
        widget.TextBox(
            **qtile_bar_icons,
            foreground=colors["07"],
            text=icons["clo"]
        ),
        widget.Clock(
            markup=True,
            format="""<span font='Hack NF Bold 9' underline='double'
                   underline_color='#4cd1e0'>%a %d - %I:%M %p</span>""",
            foreground=colors["07"]
        ),
        widget.Sep(
            padding=5,
            foreground=colors["00"],
            background=colors["00"]
        ),
        widget.Sep(
            padding=20,
            foreground=colors["09"]
        ),
        widget.Systray(
            background=colors["00"],
            padding=5
        ),
        widget.Sep(
            padding=10,
            foreground=colors["00"]
        ),
        widget.TextBox(
            **qtile_bar_icons,
            foreground=colors["09"],
            text=icons["aler"],
            mouse_callbacks={"Button1": lazy.spawn(
                "dunstctl history-pop")}
        ),
        widget.Sep(
            padding=10,
            foreground=colors["00"]
        ),
        widget.QuickExit(
            **qtile_bar_icons,
            foreground=colors["09"],
            default_text=icons["shut"],
            mouse_callbacks={"Button1": lazy.spawn("exitmenu")}
        ),
        widget.Sep(
            padding=10,
            foreground=colors["00"]
        )
        ],
        size=28,
        margin=[5, 5, 0, 5],
        background=colors["00"],
    ),),
]

# Section: ----- Hooks -----


# At Startup
@hook.subscribe.startup_once
def autostart():
    startup_apps = os.path.expanduser(
        '~/.dotfiles/.linux/.config/qtile/autostart.sh'
    )
    subprocess.Popen([startup_apps])


# After Startup
# @hook.subscribe.startup_complete
# def startup():
#     qtile.cmd_simulate_keypress([], 'XF86Mail')   # Open E-mail Client
#     qtile.cmd_simulate_keypress([mod], 'KP_End')  # Move code to group 2
