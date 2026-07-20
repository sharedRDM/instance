#!/usr/bin/env bash
# local dev only: point the local instance at a theme and build its assets.
# does what the dockerfiles do - install the theme cfg, swap the look, build.
#
#   uv sync --extra basic && ./local_theme.sh default
#   uv sync --extra tug   && ./local_theme.sh TUG
#   uv sync --extra mug   && ./local_theme.sh MUG
#
# note: this replaces `invenio webpack buildall`, do not run that after.
# if a switch looks wrong, `invenio webpack clean` first - webpack create
# never overwrites files it already collected.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
THEME="${1:-TUG}"
INVENIO="$HERE/.venv/bin/invenio"
VAR="$HERE/.venv/var/instance"
LESS_DIR="$VAR/assets/less/invenio_override"

# instance file that imports curations, which only TUG/MUG have
MAPPING="assets/js/invenio_app_rdm/overridableRegistry/mapping.js"

# ============================================================================
# what each theme needs: a cfg, and which look files to swap in.
# TUG has no swaps - the theme package already ships the TUG look.
# ============================================================================
CFG="" ; VARIABLES="" ; OVERRIDES="" ; MAPPING_SRC=""
case "$THEME" in
  default)
    CFG="themes/override-basic/invenio.cfg"
    VARIABLES="themes/override-basic/variables.less"
    MAPPING_SRC="themes/override-basic/$MAPPING"
    ;;
  TUG)
    CFG="themes/TUG/dev/invenio.cfg"
    ;;
  MUG)
    CFG="themes/MUG/invenio.cfg"
    VARIABLES="themes/MUG/variables.less"
    OVERRIDES="themes/MUG/overrides.less"
    ;;
  *)
    echo "usage: $0 default|TUG|MUG" >&2
    exit 1
    ;;
esac

# ============================================================================
# steps
# ============================================================================

install_config() {
  # the theme cfgs expect these from the dockerfile ENV
  export INVENIO_WEBPACKEXT_PROJECT="invenio_assets.webpack:rspack_project"
  export INVENIO_WEBPACKEXT_NPM_PKG_CLS="pynpm:PNPMPackage"

  # starts out as a symlink to the root invenio.cfg, so unlink first or we
  rm -f "$VAR/invenio.cfg"
  sed 's|<insert_keycloak_config_via_ci>|title="local", description="local", base_url="https://localhost/", realm="local"|' \
    "$HERE/$CFG" > "$VAR/invenio.cfg"

  # the images get infra from env vars, so the theme cfgs leave it out. TUG/MUG
  # set no db uri and no search prefix (TUG sets INDEX_PREFIX, which nothing
  # reads) - without the prefix the frontpage queries `global-search` and 404s.
  cat >> "$VAR/invenio.cfg" <<'PY'

SQLALCHEMY_DATABASE_URI = "postgresql+psycopg2://instance:instance@localhost/instance"
SEARCH_INDEX_PREFIX = "instance-"
ACCOUNTS_LOCAL_LOGIN_ENABLED = True
PY
}

restore_instance_assets() {
  # webpack create drops the instance assets (less/theme.config, less/site,
  # templates), copy them back like the dockerfiles do. a few are symlinked
  # to the same source, cp complains about those - ignore it.
  cp -R "$HERE/assets/." "$VAR/assets/" 2>/dev/null || true
}

apply_look() {
  # reset to what the theme package ships first: webpack create does not
  # overwrite what it already collected so otherwise the previous run's
  # colours stick around.
  local pkg
  pkg="$("$HERE/.venv/bin/python" -c 'import invenio_override, os; print(os.path.join(os.path.dirname(invenio_override.__file__), "assets/semantic-ui/less/invenio_override"))')"

  # first, then only ever touch real files inside it.
  if [ -L "$LESS_DIR" ]; then
    local real; real="$(cd "$LESS_DIR" && pwd -P)"
    rm "$LESS_DIR"
    cp -R "$real" "$LESS_DIR"
  fi

  # dest may also be a per-file symlink into the package/repo - drop the link
  # (never the target) before copying, so we always write a real file.
  swap() {
    if [ -L "$2" ]; then rm -f "$2"; fi
    cp "$1" "$2"
  }

  swap "$pkg/variables.less" "$LESS_DIR/variables.less"
  swap "$pkg/overrides.less" "$LESS_DIR/overrides.less"

  [ -n "$VARIABLES" ]   && swap "$HERE/$VARIABLES"   "$LESS_DIR/variables.less"
  [ -n "$OVERRIDES" ]   && swap "$HERE/$OVERRIDES"   "$LESS_DIR/overrides.less"
  [ -n "$MAPPING_SRC" ] && swap "$HERE/$MAPPING_SRC" "$VAR/$MAPPING"
  return 0
}

# ============================================================================
# run
# ============================================================================
echo "==> theme: $THEME"

install_config

"$INVENIO" collect --verbose
"$INVENIO" webpack create

restore_instance_assets
apply_look

"$INVENIO" webpack install
"$INVENIO" webpack build

echo "==> done, now: invenio-cli run"
