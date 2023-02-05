# Antonio Sarosi
# https://youtube.com/c/antoniosarosi
# https://github.com/antoniosarosi/dotfiles

# Theming for Qtile

from os import path
import json


def set_theme():
    theme = "dark"

    config = path.expanduser("~/.config/qtile/config.json")
    if path.isfile(config):
        with open(config) as f:
            theme = json.load(f)["theme"]
    else:
        with open(config, "w") as f:
            f.write(f'{{"theme": "{theme}"}}\n')

    theme_file = path.expanduser(f"~/.config/qtile/themes/{theme}.json")
    if not path.isfile(theme_file):
        raise Exception(f'"{theme_file}" does not exist')

    with open(path.join(theme_file)) as f:
        return json.load(f)


if __name__ == "themes.theme":
    colors = set_theme()
