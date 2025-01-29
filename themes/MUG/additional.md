# Adding Publications
.
.
.

**after introducing new packages - lom & marc**
```bash
# opensearchpy.exceptions.NotFoundError: NotFoundError(404, 'index_not_found_exception', 'no such index [instance-marc21records-marc21]', instance-marc21records-marc21, index_or_alias)

invenio db create  # to create global-search tables
invenio lom rebuild-index
invenio marc21 rebuild-index
invenio global-search rebuild-database
```
