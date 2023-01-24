# ----- Imports ----- #
import os
from libqtile.command.client import InteractiveCommandClient
from libqtile.command import lazy


# ----- API Fuctions (Must be executed) ----- #
MOVESPECIFICWINDOWTOGROUP = os.path.expanduser(
    '~/.dotfiles/.linux/.config/qtile/API_COMMANDS/move_x_window_togroup.py'
)


# ----- Functions ----- #
class Functions:

    @staticmethod
    def movewindowtogroup(wm_class, groupname):
        @lazy.function
        def __inner(qtile):
            qtile.cmd_spawn(
                f"{MOVESPECIFICWINDOWTOGROUP} {wm_class} {groupname}"
            )
        return __inner

    @staticmethod
    @lazy.function
    def minimize_all(qtile):
        for win in qtile.current_group.windows:
            if hasattr(win, "toggle_minimize"):
                win.toggle_minimize()


if __name__ == "__main__":
    print("This is an utilities module")
