# Adding Publications

## Invenio: Database and Index Management after Installing New Packages

When introducing new packages such as **lom** and **marc**, or after performing a **version migration of invenio-app-rdm**, it is essential to ensure that all required tables and indices are correctly set up.

---

### Common Issue: Missing Indices

After installing **lom** or **marc**, you may encounter the following error:

```bash
opensearchpy.exceptions.NotFoundError: NotFoundError(404, 'index_not_found_exception', 'no such index [instance-marc21records-marc21]', instance-marc21records-marc21, index_or_alias)
```

This indicates that the required search indices are missing and need to be rebuilt.

---

### Steps to Fix

**To see the publication tap in Overview (dashboard) the user has to have admin role or role bellow.**


#### **Create Admin User and Assign Roles**
```bash
# Create an admin user
invenio users create admin-v2@demo.org --password 123456 --active --confirm

# Assign the admin role to the user
invenio roles add admin-v2@demo.org admin

#### Add Publication (marc21) roles
```bash
invenio roles create Marc21Curator
invenio roles create Marc21Manager
invenio roles create Marc21Creator
```

#### **Handle Database Migrations**

If the new package installation includes database schema changes or if you performed an **Invenio version migration**, you need to run database migrations:

```bash
invenio alembic upgrade  # applies database migrations to create missing tables

```

#### **Create Global-Search Tables**

Before initializing indices, ensure the database has the required tables for global search:

```bash
invenio db create
```

#### **Rebuild Indices for Newly Installed Packages**

After adding **lom** or **marc**, rebuild their respective indices:

```bash

invenio marc21 rebuild-index
invenio global-search rebuild-database
```

#### ⚠️ **Warning: Destroy and Reinitialize OpenSearch Indices (If Needed)**

⚠️ **Warning:** If indices are outdated or corrupted, destroying them will remove all indexed data. Only proceed if necessary. After destruction, you must reinitialize and rebuild all indices to restore functionality.

```bash
invenio index destroy --yes-i-know
invenio index init
```

#### **Rebuild All Indices**

After initializing indices, rebuild all required search indices:

```bash
invenio rdm rebuild-all-indices
invenio marc21 rebuild-index
invenio global-search rebuild-database
```

#### **Load Demo Records for Publications**  
If you want to try the demo records for publications, run:  
```bash
invenio marc21 demo -b -m -n 10
```

## **Disabling Educational Resources (OER) for MUG**
The **educational resources schema (`lom`)** is not required for the MUG repository. Therefore, it has been removed from the **global search configuration** and set to `False`.  

If, in the future, MUG decides to enable **educational resources**, the developer can follow these steps:

### **1. Install invenio-records-lom**
Locally install invenio-records-lom, update the uv.lock and push the changes. **TODO: this should be somehow automatic.**

### **2. Update configuration variables**
In the configuration file, set the following variable to `True`:
```bash
OVERRIDE_SHOW_EDUCATIONAL_RESOURCES = True
```

### **2. Add the schema back to the Global Search Configuration**
Modify the GLOBAL_SEARCH_SCHEMAS dictionary by adding the lom schema:
```python
GLOBAL_SEARCH_SCHEMAS = {
    "lom": {
        "schema": "lom",
        "name_l10n": _("OER"),
    },
    "rdm": {
        "schema": "rdm",
        "name_l10n": _("Research Result"),
    },
    "marc21": {
        "schema": "marc21",
        "name_l10n": _("Publication"),
    },
}
```

### **3. Run the database migration**
To create the tables necessary for OER run the database migrations with:
```bash
invenio alembic upgrade
```

### **4. Rebuild Global Search and Indices**
After reintroducing the schema, the global search database and indices need to be recreated:
```bash
invenio global-search rebuild-database
invenio index destroy --yes-i-know
invenio index init
invenio rdm rebuild-all-indices
```

# MUG Customization

## UI

- We change the name of the Uploads dashboard menu with Research Results.
```python
USER_DASHBOARD_MENU_OVERRIDES = {
      "uploads": {
        "text": _("Research Results"),
      },
}
"""Override the Uploads menu title"""
```
