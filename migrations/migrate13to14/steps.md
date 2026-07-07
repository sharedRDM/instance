# Migrate from v13 to v14

> Notes for this instance:
>
> - Uses invenio-saml, not invenio-edugain — ignore the edugain env vars below.
> - Branding comes from invenio-override and themes/<TUG|MUG>/, not invenio-theme-tugraz.
> - If alembic upgrade fails on removed revisions where the DB
>   was on a v14 beta — clean those stale heads out of alembic_version for that
>   DB first see RUNBOOK.md. Don't copy revision ids from another instance.
> - The resource-type step publication-thesis to publication-dissertation does
>   nothing if there are no thesis records — safe either way.
> - marc21/lom role needs use role.name (the v14 role.id change was reverted).

this time are not only InvenioRDM core features added to our instance
but also our own build feature invenio-edugain, which needs configuration

## set env variables

```
REQUESTS_COMMENT_PREVIEW_LIMIT = 10 # default
REQUESTS_LOCKING_ENABLED = True

EDUGAIN_LOGIN_ENABLED = True
```

## update env variables

## Update Services

## Data Migration

configure `postgresql.conf` `timezone = 'Europe/Vienna'` to `timezone = 'UTC'` and `log_timezone = 'Europe/Vienna'` to `log_timezone = 'UTC'` and reload with `SELECT pg_reload_conf();`


```bash
invenio alembic upgrade
```

# run the migration script!

add the new vocabulary type first. run `invenio rdm-records add-to-fixture <vocabulary fixture>` with following values

- datetypes
- descriptiontypes
- licenses
- relationtypes
- resourcetypes
- contributorsroles
- creatorsroles
- titletypes

```
invenio shell ./migrations/migrate13to14/migrate_13_0_to_14_0.py
```

```
from flask import current_app
from invenio_access.permissions import system_identity
from invenio_oaiserver.percolator import _build_percolator_index_name
from invenio_rdm_records.proxies import current_rdm_records
from invenio_search.proxies import current_search_client
from invenio_search.utils import build_alias_name

index = current_app.config["OAISERVER_RECORD_INDEX"]
percolator_index = _build_percolator_index_name(index)
record_index = build_alias_name(index)

# Fetch the mapping from the "live" index
record_mapping = current_search_client.indices.get_mapping(index=record_index)
assert len(record_mapping) == 1
percolator_mappings = list(record_mapping.values())[0]["mappings"]

# Update the mapping
current_search_client.indices.put_mapping(
    index=percolator_index,
    body=percolator_mappings,
)

# Reindex all percolator queries from OAISets
oaipmh_service = current_rdm_records.oaipmh_server_service
oaipmh_service.rebuild_index(identity=system_identity)
```


# reindex

curl -X DELETE http://localhost:9200/_data_stream/auditlog-audit-log-v1.0.0
curl -X DELETE http://localhost:9200/_data_stream/.ds-auditlog-audit-log-v1.0.0-000001
```
invenio index destroy --yes-i-know
invenio index init
# if you have records custom fields
invenio rdm-records custom-fields init
# if you have communities custom fields
invenio communities custom-fields init
invenio rdm rebuild-all-indices
```
