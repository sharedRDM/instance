"""
Script that injects a given yaml config into arguments of an invenio.cfg class.
"""

import yaml
import sys
import argparse

parser = argparse.ArgumentParser()

parser.add_argument('--source-filename', type=str, required=True)
parser.add_argument('--dest-filename', type=str, required=True)
parser.add_argument('--node', type=str, required=True)
parser.add_argument('--placeholder', type=str, required=True)

args = parser.parse_args()

auth_config = ""
with open(args.source_filename) as f:
    data = yaml.safe_load(f)
    for key, _ in data.items():
        if key == args.node:
            for node_key, val in data[key].items():
                if isinstance(val, str):
                    auth_config += f'{node_key}="{val}",\n'
                else:
                    auth_config += f'{node_key}={val},\n'

with open(args.dest_filename, "r") as f:
    config = f.read()
    config = config.replace(args.placeholder, auth_config)

with open(args.dest_filename, "w") as f:
    f.write(config)
