"""JS/CSS Webpack bundles for instance."""

from invenio_assets.webpack import WebpackThemeBundle

theme = WebpackThemeBundle(
    __name__,
    "assets",
    default="semantic-ui",
    themes={
        "semantic-ui": dict(
            entry={
                # Add your webpack entrypoints
                "invenio-app-rdm-overrides": "./js/invenio_app_rdm/overridableRegistry/mapping.js",
            },
        ),
    },
)
