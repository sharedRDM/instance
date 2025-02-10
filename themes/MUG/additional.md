# Adding Publications

.
.
.

# Invenio: Database and Index Management after Installing New Packages

When introducing new packages such as **lom** and **marc**, or after performing a **version migration of invenio-app-rdm**, it is essential to ensure that all required tables and indices are correctly set up.

---

## Common Issue: Missing Indices

After installing **lom** or **marc**, you may encounter the following error:

```bash
opensearchpy.exceptions.NotFoundError: NotFoundError(404, 'index_not_found_exception', 'no such index [instance-marc21records-marc21]', instance-marc21records-marc21, index_or_alias)
```

This indicates that the required search indices are missing and need to be rebuilt.

---

## Steps to Fix

### **Handle Database Migrations**

If the new package installation includes database schema changes or if you performed an **Invenio version migration**, you need to run database migrations:

```bash
invenio alembic upgrade  # applies database migrations to create missing tables

```

### **Create Global-Search Tables**

Before initializing indices, ensure the database has the required tables for global search:

```bash
invenio db create
```

### **Rebuild Indices for Newly Installed Packages**

After adding **lom** or **marc**, rebuild their respective indices:

```bash

invenio marc21 rebuild-index
invenio global-search rebuild-database
```

### ⚠️ **Warning: Destroy and Reinitialize OpenSearch Indices (If Needed)**

⚠️ **Warning:** If indices are outdated or corrupted, destroying them will remove all indexed data. Only proceed if necessary. After destruction, you must reinitialize and rebuild all indices to restore functionality.

```bash
invenio index destroy --yes-i-know
invenio index init
```

### **Rebuild All Indices**

After initializing indices, rebuild all required search indices:

```bash
invenio rdm rebuild-all-indices
invenio marc21 rebuild-index
invenio global-search rebuild-database
```

### **Load Demo Records for Publications**  
If you want to try the demo records for publications, run:  
```bash
invenio marc21 demo -b -m -n 10
```

---
