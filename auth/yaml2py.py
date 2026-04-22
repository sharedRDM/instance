"""
Script that injects a given yaml config into arguments of an invenio.cfg class.

Usage python yaml2py --source-filename your_config.yaml --dest-filename your_invenio.cfg --node rdm --placeholder <inject_config_here>
"""

import argparse
import sys
import os
import yaml

parser = argparse.ArgumentParser()

parser.add_argument("--source-filename", type=str, required=True)
parser.add_argument("--dest-filename", type=str, required=True)
parser.add_argument("--node", type=str, required=True)
parser.add_argument("--placeholder", type=str, required=True)

args = parser.parse_args()

secrets = {}
secret_env = os.environ.get("YAML2PY_SECRETS")
if secret_env:
    secrets_list = secret_env.split(",")
    for one_secret_str in secrets_list:
        key_val = one_secret_str.split("=")
        secrets[key_val[0].lower()] = key_val[1]

auth_config = ""
with open(args.source_filename) as f:
    data = yaml.safe_load(f)
    for key, _ in data.items():
        if key == args.node:
            for node_key, val in data[key].items():
                if isinstance(val, str) and val == "<secret>":
                    auth_config += f'{node_key}="{secrets[node_key]}",\n'
                elif isinstance(val, str):
                    auth_config += f'{node_key}="{val}",\n'
                else:
                    auth_config += f"{node_key}={val},\n"

with open(args.dest_filename, "r") as f:
    config = f.read()
    config = config.replace(args.placeholder, auth_config)

with open(args.dest_filename, "w") as f:
    f.write(config)
