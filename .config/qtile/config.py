# {{{ Libraries

from themes.theme import colors
from libqtile import bar, layout, widget
from libqtile.config import (Click, Drag, Group, ScratchPad, DropDown,
                             Key, Match, Screen)
from libqtile.lazy import lazy
from libqtile.command import lazy
# }}}

# {{{ Variable Definitions

window_gap = 5
bar_gap = 5
bar_thickness = 24
terminal = "alacritty"
auto_fullscreen = True
bring_front_click = "floating_only"
cursor_warp = False
dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = False
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None
wmname = "LG3D"
# }}}

# {{{ Layouts

layouts = [
    layout.MonadTall(
        border_focus=colors["normal"]["red"],
        border_normal=colors["background"],
        border_width=2,
        margin=window_gap,
        single_border_width=0,
        ratio=0.5,
        change_ratio=0.05,
        change_size=20,
        max_ratio=0.75,
        min_ratio=0.25,
        min_secondary_size=85,
        new_client_position="bottom"
    )
]

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
        Match(wm_class="VirtualBox Machine")
    ],
    border_focus=colors["bright"]["black"],
    border_normal=colors["bright"]["black"],
    border_width=1,
    fullscreen_border_width=0,
    max_border_width=0
)
# }}}

# {{{ Workspaces

groups = [
    ScratchPad("scratchpad", [
        DropDown("term", "alacritty", opacity=0.8),
        DropDown("qtile shell", "alacritty --command qtile shell",
                 x=0.05, y=0.4, width=0.9, height=0.6, opacity=0.9,
                 on_focus_lost_hide=True),
        DropDown("rdp", terminal + " -e 'runrdp'",
                 height=0.5, width=0.5, x=0.25, y=0.25, opacity=1.0)
    ]),
    Group(
        name="1",
        label="󰖟",
        layout="monadtall"
    ),
    Group(
        name="2",
        label="󰅩",
        layout="monadtall"
    ),
    Group(
        name="3",
        label="󰉖",
        layout="monadtall"
    ),
    Group(
        name="4",
        label="󰓇",
        layout="monadtall"
    ),
    Group(
        name="5",
        label="󰓓",
        layout="monadtall",
        matches=[
            Match(wm_class="Steam")
        ]
    ),
    Group(
        name="6",
        label="󰍺",
        layout="monadtall",
        matches=[
            Match(wm_class="VirtualBox Manager"),
            Match(wm_class="VirtualBox Machine")
        ]
    ),
    Group(
        name="9",
        label="󰢹",
        layout="monadtall",
        matches=[
            Match(wm_class="xfreerdp")
        ],
        init=False,
        persist=False
    )
]
# }}}


# {{{ Keybindings

# {{{ Custom keybinding functions

@lazy.window.function
def move_floating_window(window, x: int = 0, y: int = 0):
    if window.floating is True or \
       window.qtile.current_layout.name == 'floating':
        new_x = window.float_x + x
        new_y = window.float_y + y
        window.cmd_set_position_floating(new_x, new_y)


@lazy.window.function
def resize_floating_window(window, width: int = 0, height: int = 0):
    if window.floating is True or \
       window.qtile.current_layout.name == 'floating':
        window.cmd_set_size_floating(window.width + width,
                                     window.height + height)


@lazy.function
def minimize_all(qtile):
    for win in qtile.current_group.windows:
        if hasattr(win, "toggle_minimize"):
            win.toggle_minimize()
# }}}


mod = "mod4"
keys = [Key(key[0], key[1], *key[2:]) for key in [

    # {{{ Move Floating Window

    ([mod, "mod1"], "l", move_floating_window(x=50)),
    ([mod, "mod1"], "j", move_floating_window(x=-50)),
    ([mod, "mod1"], "k", move_floating_window(y=50)),
    ([mod, "mod1"], "i", move_floating_window(y=-50)),
    # }}}

    # {{{ Resize Floating Window

    ([mod, "control", "mod1"], "l", resize_floating_window(width=50)),
    ([mod, "control", "mod1"], "j", resize_floating_window(width=-50)),
    ([mod, "control", "mod1"], "k", resize_floating_window(height=50)),
    ([mod, "control", "mod1"], "i", resize_floating_window(height=-50)),
    # }}}

    # {{{ Move Focus

    ([mod], "i", lazy.layout.up()),
    ([mod], "j", lazy.layout.left()),
    ([mod], "k", lazy.layout.down()),
    ([mod], "l", lazy.layout.right()),
    # }}}

    # {{{ Move Window

    ([mod, "shift"], "i", lazy.layout.shuffle_up()),
    ([mod, "shift"], "j", lazy.layout.swap_left()),
    ([mod, "shift"], "k", lazy.layout.shuffle_down()),
    ([mod, "shift"], "l", lazy.layout.swap_right()),
    ([mod], "space", lazy.layout.flip()),
    # }}}

    # {{{ Resize Window

    ([mod, "control"], "i", lazy.layout.grow()),
    ([mod, "control"], "j", lazy.layout.shrink_main()),
    ([mod, "control"], "k", lazy.layout.shrink()),
    ([mod, "control"], "l", lazy.layout.grow_main()),
    ([mod], "f", lazy.layout.maximize()),
    ([mod], "n", lazy.layout.normalize()),
    ([mod, "control"], "space", lazy.layout.reset()),
    # }}}

    # {{{ Window Commands

    ([mod, "shift"], "c", lazy.spawn("xkill")),
    ([mod], "c", lazy.window.toggle_minimize()),
    ([mod, "control"], "c", lazy.window.kill()),
    ([mod], "v", lazy.window.toggle_floating()),
    ([mod, "control"], "f", lazy.window.toggle_fullscreen()),
    # }}}

    # {{{ Layout manipulation

    ([mod], "Tab", lazy.next_layout()),
    # }}}

    # {{{ Session Commands

    ([mod], "BackSpace", lazy.reload_config()),
    ([mod, "control"], "BackSpace", lazy.restart()),
    ([mod], "Delete", lazy.spawn("slock")),
    ([mod, "control"], "Delete", lazy.shutdown()),
    # }}}

    # {{{ Applications

    # ([mod], "r", lazy.spawncmd()),
    ([mod], "r", lazy.spawn("rofi -modi drun,run -show drun")),
    ([mod], "Return", lazy.spawn(terminal)),
    ([mod], "period", lazy.spawn("rofi -modi emoji -show emoji")),
    ([mod], "b", lazy.spawn("changebg")),
    ([mod], "q", lazy.spawn("firefox")),
    ([mod], "w", lazy.spawn("code")),
    ([mod], "e", lazy.spawn("thunar")),
    ([mod], "s", lazy.spawn("steam")),
    # }}}

    # {{{ Media Keys

    ([], "XF86Explorer", lazy.spawn("thunar")),
    ([], "XF86HomePage", minimize_all()),
    ([], "XF86Mail", lazy.spawn("thunderbird")),
    ([], "XF86Calculator", lazy.spawn("galculator")),
    ([], "XF86Tools", lazy.spawn("qtile run-cmd -g 4 spotify")),
    ([], "XF86AudioStop", lazy.spawn("""dbus-send --print-reply
        --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2
        org.mpris.MediaPlayer2.Player.Pause""")),
    ([], "XF86AudioPrev", lazy.spawn("""dbus-send --print-reply
        --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2
        org.mpris.MediaPlayer2.Player.Previous""")),
    ([], "XF86AudioPlay", lazy.spawn("""dbus-send --print-reply
        --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2
        org.mpris.MediaPlayer2.Player.PlayPause""")),
    ([], "XF86AudioNext", lazy.spawn("""dbus-send --print-reply
        --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2
        org.mpris.MediaPlayer2.Player.Next""")),
    ([], "XF86AudioMute", lazy.spawn("pulsemixer --toggle-mute")),
    ([], "XF86AudioLowerVolume", lazy.spawn("changeVolume -1")),
    ([], "XF86AudioRaiseVolume", lazy.spawn("changeVolume +1")),
    # }}}

    # {{{ Scratchpads

    ([mod], "Tab", lazy.screen.next_group()),
    ([mod, "shift"], "Tab", lazy.screen.prev_group()),
    # }}}

    # {{{ Scratchpads

    ([], 'F11', lazy.group['scratchpad'].dropdown_toggle('term')),
    ([], 'F12', lazy.group['scratchpad'].dropdown_toggle('qtile shell')),
    ([mod], 'd', lazy.group['scratchpad'].dropdown_toggle('rdp'))
    # }}}
]]

mouse = [
    Drag([mod], "Button1",
         lazy.window.set_position_floating(),
         start=lazy.window.get_position()
         ),

    Drag([mod], "Button3",
         lazy.window.set_size_floating(),
         start=lazy.window.get_size()
         ),

    Click([mod], "Button2",
          lazy.window.bring_to_front()
          ),
]

for i in groups:
    if len(i.name) == 1:
        keys.extend([
            Key([mod], i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
                ),
            Key([mod, "shift"], i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(
                    i.name
                    ),
                ),
            Key([mod, "control"], i.name, lazy.window.togroup(i.name),
                desc="move focused window to group {}".format(i.name))
        ])
# }}}


# {{{ Widgets

widget_defaults = dict(
    background=colors["background"],
    foreground=colors["foreground"],
    font="Hack NF Bold",
    fontsize=12,
    padding=5,
)
extension_defaults = widget_defaults.copy()


def Spacer(p):
    spacer = widget.Spacer(
        length=p,
    )
    return spacer


def Icon(i, c):
    icon = widget.TextBox(
        font="Material Design Icons Desktop",
        text=i,
        fontsize=18,
        padding=0,
        foreground=c,
    )
    return icon


def GroupBox():
    groupbox = widget.GroupBox(
        font="Material Design Icons",
        fontsize=26,
        highlight_method="line",
        urgent_alert_method="line",
        active=extension_defaults["foreground"],
        inactive=colors["bright"]["black"],
        highlight_color=extension_defaults["background"],
        this_current_screen_border=colors["normal"]["red"],
        this_screen_border=colors["normal"]["red"],
        borderwidth=2,
        disable_drag=True,
        use_mouse_wheel=False
    )
    return groupbox


def TaskList():
    tasklist = widget.TaskList(
            markup=True,
            border=colors["normal"]["red"],
            unfocused_border=colors["bright"]["black"],
            urgent_border=colors["urgent"],
            highlight_method="block",
            markup_focused="<span font='Hack NF Bold 9'> {}</span>",
            markup_normal="<span font='Hack NF Bold 9'> {}</span>",
            markup_floating="<span font='Hack NF Bold 9'> [F] {}</span>",
            markup_minimized="<span font='Hack NF Bold 9'> [-] {}</span>",
            markup_maximized="<span font='Hack NF Bold 9'> [+] {}</span>",
            borderwidth=1,
            icon_size=0,
            margin_y=2,
            max_title_width=128,
            padding_x=3,
            padding_y=3,
            rounded=True,
            spacing=10,
            title_width_method="uniform",
            urgent_alert_method="text"
        )
    return tasklist


def CheckUpdates(c):
    checkupdates = widget.CheckUpdates(
        distro="Arch",
        colour_have_updates=c,
        display_format="""<span font='Hack NF Bold 9' underline='double'
                        underline_color='{color}'
                        >{a} Update(s)</span>""".format(
                            color=c,
                            a="{updates}"
                        ),
        no_update_string="""<span font='Hack NF Bold 9' underline='double'
                        underline_color='{color}'
                        >No Updates</span>""".format(
                            color=c,
                        ),
        colour_no_updates=c,
        execute=terminal + " --hold --command sudo pacman -Syyu"
    )
    return checkupdates


def CPU(c):
    cpu = widget.CPU(
        update_interval=0.5,
        mouse_callbacks={"Button1": lazy.spawn(terminal + " --command htop")},
        format="""<span font='Hack NF Bold 9' underline='double'
                underline_color='{color}'>CPU {a}%</span>""".format(
                    color=c,
                    a="{load_percent}"
                )
    )
    return cpu


def CPUThermalSensor(c):
    cpu = widget.ThermalSensor(
        foreground=c,
        fmt="""<span font='Hack NF Bold 9' underline='double'
            underline_color='{color}'>CPU {a}</span>""".format(
                color=c,
                a="{}"
            ),
        tag_sensor="Package id 0",
        threshold=90,
        update_interval=1
    )
    return cpu


def GPUThermalSensor(c):
    gpu = widget.ThermalSensor(
        foreground=c,
        fmt="""<span font='Hack NF Bold 9' underline='double'
            underline_color='{color}'>GPU {a}</span>""".format(
                color=c,
                a="{}"
            ),
        tag_sensor="edge",
        threshold=90,
        update_interval=1
    )
    return gpu


def Memory(c):
    ram = widget.Memory(
            markup=True,
            format="""<span font='Hack NF Bold 9' underline='double'
                underline_color='{color}'>RAM {a}{b}/{c}{d}</span>""".format(
                    color=c,
                    a="{MemUsed:.0f}",
                    b="{mm}",
                    c="{MemTotal:.0f}",
                    d="{mm}"
                ),
            foreground=c,
            measure_mem="M",
            mouse_callbacks={"Button1": lazy.spawn(
                terminal + " -e htop")}
    )
    return ram


def Pomodoro(c):
    pomodoro = widget.Pomodoro(
        markup=True,
        color_active=c,
        color_inactive=c,
        color_break=c,
        fmt="""<span font='Hack NF Bold 9' underline='double'
            underline_color='{color}'>{br}</span>""".format(color=c, br="{}"),
        prefix_active="""<span font='Hack NF Bold 9' underline='double'
                        underline_color='{color}'></span>""".format(color=c),
        prefix_inactive="""<span font='Hack NF Bold 9' underline='double'
                        underline_color='{color}'
                        >25min</span>""".format(color=c),
        prefix_break="""<span font='Hack NF Bold 9' underline='double'
                        underline_color='{color}'
                        >Short Break ! </span>""".format(color=c),
        prefix_long_break="""<span font='Hack NF Bold 9' underline='double'
                            underline_color='{color}'
                            >Take a Break ! </span>""".format(color=c),
        prefix_paused="""<span font='Hack NF Bold 9' underline='double'
                        underline_color='{color}'
                        >PAUSE</span>""".format(color=c),
        num_pomodori=4,
        length_pomodori=25,
        length_short_break=5,
        length_long_break=15
    )
    return pomodoro


def Clock(c):
    clock = widget.Clock(
        format="""<span font='Hack NF Bold 9' underline='double'
                underline_color='{color}'
                >%a %d - %I:%M %p</span>""".format(color=c)
    )
    return clock


def Systray():
    systray = widget.Systray(
        padding=5
    )
    return systray


def QuickExit(i, c):
    quickexit = widget.QuickExit(
        foreground=c,
        default_text=i,
        fontsize=18,
        mouse_callbacks={"Button1": lazy.spawn("exitmenu")}
    )
    return quickexit
# }}}


# {{{ Bars

screens = [
    Screen(
        top=bar.Bar(
            [
                Spacer(10),
                GroupBox(),
                Spacer(10),
                TaskList(),
                Spacer(10),
                Icon("󰂜", colors["normal"]["red"]),
                CheckUpdates(colors["normal"]["red"]),
                Spacer(10),
                Icon("󰍛", colors["foreground"]),
                CPU(colors["foreground"]),
                Spacer(10),
                Icon("󰸁", colors["normal"]["blue"]),
                CPUThermalSensor(colors["normal"]["blue"]),
                Spacer(10),
                Icon("󰸁", colors["normal"]["blue"]),
                GPUThermalSensor(colors["normal"]["blue"]),
                Spacer(10),
                Icon("󱘲", colors["normal"]["magenta"]),
                Memory(colors["normal"]["magenta"]),
                Spacer(10),
                Icon("󰔛", colors["normal"]["green"]),
                Pomodoro(colors["normal"]["green"]),
                Spacer(10),
                Icon("󰸗", colors["foreground"]),
                Clock(colors["foreground"]),
                Spacer(10),
                Systray(),
                Spacer(10),
                QuickExit("󰐦", colors["bright"]["black"]),
                Spacer(10)
            ],
            bar_thickness,
            background=extension_defaults["background"],
            border_width=5,
            border_color=extension_defaults["background"],
            margin=[bar_gap, bar_gap, 0, bar_gap],
            opacity=1
        ),
    ),
]
# }}}
