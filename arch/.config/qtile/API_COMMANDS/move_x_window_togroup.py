#!/usr/bin/env python3

# ----- Imports ----- #
from sys import argv
from libqtile.command.client import InteractiveCommandClient


# ----- Function ----- #
def move_window_togroup(wm_class, groupname):
    c = InteractiveCommandClient()
    for id in c.items("window")[1]:
        windows = c.window[id].info()
        if "wm_class" in windows:
            for win_class in windows["wm_class"]:
                if win_class == wm_class:
                    c.window[id].togroup(groupname, switch_group=False)


if __name__ == "__main__":
    move_window_togroup(argv[1], argv[2])
