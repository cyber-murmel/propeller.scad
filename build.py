from subprocess import run
from json import load
from shlex import split

OPENSCAD = "openscad"
CAD_FILE = "propeller.scad"
CONFIG_FILE = "propeller.json"
COLORSCHEME = "Tomorrow Night"

build_str = f'{OPENSCAD} {CAD_FILE} --colorscheme "{COLORSCHEME}"'

with open(CONFIG_FILE) as config_json:
    parameter_sets = load(config_json)["parameterSets"]


def run_command(command):
    print(command)
    run(split(command))


for file_ext in [
    "png",
    "stl",
]:
    # for file_ext in ["png", ]:
    run_command(f"{build_str} -o propeller.{file_ext}")
    for parameter_set in parameter_sets:
        run_command(
            f"{build_str} -o propeller_{parameter_set}.{file_ext} -p {CONFIG_FILE} -P {parameter_set}"
        )
