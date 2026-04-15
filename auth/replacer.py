"""
Script that injects given values in the placeholders place.

Usage: python replacer.py --dest-filename invenio.cfg --placeholders <placeholder1>,<placeholder2>  --values value1,value2
"""

import argparse
import sys

import yaml

parser = argparse.ArgumentParser()

parser.add_argument("--dest-filename", type=str, required=True)
parser.add_argument("--placeholders", type=str, required=True)
parser.add_argument("--values", type=str, required=True)

args = parser.parse_args()

placeholders = args.placeholders.split(",")
values = args.values.split(",")

with open(args.dest_filename, "r") as f:
    config = f.read()
    for i in range(len(placeholders)):
        config = config.replace(placeholders[i], values[i])

with open(args.dest_filename, "w") as f:
    f.write(config)
