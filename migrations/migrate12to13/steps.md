# Migrate from v12 to v13

## set env variables

```bash
RDM_USER_MODERATION_ENABLED = True
"""User moderation feature enabled."""

RDM_SEARCH_SORT_BY_VERIFIED = True
"""Enable the sorting of records by verified."""

USERS_RESOURCES_ADMINISTRATION_ENABLED = True
"""Enable user administration."""

USERS_RESOURCES_GROUPS_ENABLED = True
"""Config to enable features related to existence of groups."""

COMMUNITIES_ADMINISTRATION_DISABLED = False  # this enables it
"""Enable communities administration."""

APP_RDM_SUBCOMMUNITIES_LABEL = "Projects"
"""Label for subcommunities in communities browse page."""

COMMUNITIES_SHOW_BROWSE_MENU_ENTRY = True
"""Toggle to show or hide the 'Browse' menu entry for communities."""

JOBS_ADMINISTRATION_ENABLED = True
"""Enable Jobs administration view."""
```

## update env variables

- change from `APP_ALLOWED_HOSTS` to `TRUSTED_HOSTS` due flask >= 3

## Update Services


### Configuration change for nginx


The new PDF file previewer is based on pdfjs-dist v4, which uses ECMAScript
modules (.mjs) over CommonJS files (.js). These files are not registered in the
default configuration for nginx. This can result in the MIME type being reported
incorrectly, and thus being blocked by the browser, leading to a broken PDF
preview.

Luckily, this can be simply fixed by adding a custom types entry; e.g. in the
http block in nginx.conf (cf. this Cookiecutter PR).

```
include       /etc/nginx/mime.types;
default_type  application/octet-stream;
types {
    # Tell nginx that ECMAScript modules are also JS
    application/javascript js mjs;
}
```

## Data Migration

Because the new instance version will no longer mandatory depend on invenio-records-lom and invenio-records-marc21, some errors can appear when trying to run the database migration. The steps to resolve these are the following:

1. Login/enter the environment where the instance is deployed.
2. Access the database and run ```select * from alembic_version```.
3. In the invenio-records-lom and invenio-records-marc21 look for revisions id that are found in the results of the query at the second step.
4. Delete the migrations you do not need.

After that you can run the following commands:

```bash
invenio db create
```

run this to create any new table

```bash
invenio alembic upgrade
```

this has to be done to add maybe other small changes to the database too


# reindex

```
invenio rdm rebuild-all-indices
```
