#!/usr/bin/env bash
# local dev only: run the dev server WITH the Flask debugger.
#
# invenio-cli run can't enable the debugger - it sets FLASK_DEBUG, which this
# Flask version ignores; only `invenio run --debug` turns it on. this starts
# the celery worker plus the web server with the debugger active.
#
# services must be up first (once):  invenio-cli services setup
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
export INVENIO_INSTANCE_PATH="$HERE/.venv/var/instance"

# celery worker in the background; stopped when this script exits
"$HERE/.venv/bin/celery" -A invenio_app.celery worker --beat --events \
  --loglevel INFO --queues celery,low &
WORKER=$!
trap 'kill "$WORKER" 2>/dev/null || true' EXIT

# web server with the Flask debugger enable
"$HERE/.venv/bin/invenio" run --debug \
  --cert "$HERE/docker/nginx/test.crt" --key "$HERE/docker/nginx/test.key" \
  --host 127.0.0.1 --port 5000 \
  --extra-files "$INVENIO_INSTANCE_PATH/invenio.cfg"
