# v13 → v14 migration

Steps to migrate an instance to invenio-app-rdm 14.0.0rc2. Run these on the
instance — locally, or `invenio ...` inside the web pod on the cluster.

Keep the new v14 features off during the migration; enable them later per tenant.

## 1. Backup
Snapshot the database and search before starting.

## 2. Postgres timezone
In `postgresql.conf` set `timezone = 'UTC'` and `log_timezone = 'UTC'`, then:
```sql
SELECT pg_reload_conf();
```

## 3. Database
```
invenio alembic upgrade
```
If the DB was previously on a v14 beta, alembic can fail on revisions that v14
removed (webhooks / github / jobs). Check `SELECT version_num FROM alembic_version`
and delete the unresolvable ones for that specific DB before upgrading. Don't copy
revision ids from another instance.

## 4. Vocabularies
```
for v in datetypes descriptiontypes licenses relationtypes resourcetypes \
         contributorsroles creatorsroles titletypes; do
  invenio rdm-records add-to-fixture "$v"
done
```

## 5. Data migration
```
invenio shell ./migrations/migrate13to14/migrate_13_0_to_14_0.py
```
- resource type `publication-thesis` → `publication-dissertation`
- request `parent_child` comment field

## 6. Reindex
Run the percolator / OAI snippet from `steps.md`, then:
```
curl -X DELETE http://localhost:9200/_data_stream/auditlog-audit-log-v1.0.0
invenio index destroy --yes-i-know
invenio index init
invenio rdm-records custom-fields init
invenio communities custom-fields init
invenio rdm rebuild-all-indices
```

## 7. Assets
```
invenio-cli assets build
```

## Rollback
Restore the database + search snapshot and revert `pyproject.toml` / `uv.lock`.
