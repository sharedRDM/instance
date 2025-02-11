#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Copyright (C) 2019-2020 CERN.
# Copyright (C) 2020-2023 Graz University of Technology.
# Copyright (C) 2024 Shared RDM.
#
# This instance project is free software; you can redistribute it and/or
# modify it under the terms of the MIT License; see LICENSE file for more
# details.

# Quit on errors
set -o errexit

# Quit on unbound symbols
set -o nounset

# Ensure Black and Flake8 are installed via uv
echo "Installing formatting tools..."
uv pip install black flake8 --system

# Run Black formatting check on the entire project
echo "Checking Python formatting with Black..."
uv run black --check .

# ----------------------------------------------------------------------------
# Additional tests can be added here as needed.
# Example:
# uv run pytest tests/
# uv run mypy .
# ----------------------------------------------------------------------------