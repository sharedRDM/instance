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

### **1. Update configuration variables**
In the configuration file, set the following variable to `True`:
```bash
OVERRIDE_SHOW_EDUCATIONAL_RESOURCES = True
```

### **2. Add the schema back to the Global Search Configuration**
Modify the GLOBAL_SEARCH_SCHEMAS dictionary by adding the lom schema:
```bash
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

### **3. Rebuild Global Search and Indices**
After reintroducing the schema, the global search database and indices need to be recreated:
```bash
invenio global-search rebuild-database
invenio index destroy --yes-i-know
invenio index init
invenio rdm rebuild-all-indices
```

# Keycloak
Adding SSO with OpenID Connect (OIDC)

```bash
from invenio_oauthclient.contrib.keycloak import KeycloakSettingsHelper

_keycloak_helper = KeycloakSettingsHelper(
    title="Meduni SSO",
    description="Meduni SSO",
    base_url="https://openid.medunigraz.at/",
    realm="invenioRDM",
    app_key="KEYCLOAK_APP_CREDENTIALS",
    legacy_url_path=False  # Remove "/auth/" between the base URL and realm names for generated Keycloak URLs (default: True, for Keycloak up to v17)
)

OAUTHCLIENT_KEYCLOAK_REALM_URL = _keycloak_helper.realm_url
OAUTHCLIENT_KEYCLOAK_USER_INFO_URL = _keycloak_helper.user_info_url
OAUTHCLIENT_KEYCLOAK_VERIFY_EXP = True  # whether to verify the expiration date of tokens
OAUTHCLIENT_KEYCLOAK_VERIFY_AUD = True  # whether to verify the audience tag for tokens
OAUTHCLIENT_KEYCLOAK_AUD = "inveniordm"  # probably the same as the client ID
OAUTHCLIENT_KEYCLOAK_USER_INFO_FROM_ENDPOINT = True  # get user info from keycloak endpoint

OAUTHCLIENT_REMOTE_APPS = {"keycloak": _keycloak_helper.remote_app}

## SET THE CREDENTIALS via .env
# INVENIO_KEYCLOAK_APP_CREDENTIALS={'consumer_key':'<YOUR.CLIENT.ID>','consumer_secret': '<YOUR.CLIENT.CREDENTIALS.SECRET>'}
```
---

# Debugging

## If you want to see defined configs
```bash
# exec UI container
docker exec -it UI_CONTAINER bash

# open invenio shell
invenio shell

# print config
print(app.config["OAUTHCLIENT_KEYCLOAK_USER_INFO_URL"])
```

