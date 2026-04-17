# InvenioRDM Cluster Setup Guide

A reference for managing users, roles, demo records, and global search on the k3s cluster via `kubectl`.

---

## 1. Prerequisites

> **TODO:** Document the preferred way to connect to the cluster (kubectl config or Rancher).
> Connection setup should be kept as local notes or in the infrastructure project.

You need `kubectl` configured and connected to the cluster before running any commands below.

---

## 2. Find the Web Pod

All `invenio` CLI commands must be run inside the web pod. First, get the current pod name:

```bash
kubectl get pod
```

Look for the pod starting with `inveniordm-web-`. The name changes on each deployment, for example:

```
inveniordm-web-6d88fcc6b5-bnk7q   2/2   Running   0   95m
```

Use this name in all `kubectl exec` commands below. Replace `<WEB_POD>` with the actual name.

---

## 3. User Setup

### 3.1 Create a local demo admin user (optional, for testing)

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio users create admin@demo.org --password 123456 --active --confirm
invenio roles add admin@demo.org admin
"
```

### 3.2 Add a Keycloak/SSO user as admin

> **Important:** The user must have logged in at least once via SSO (Keycloak) before roles can be assigned. The first login creates the account in the database.

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio roles add <your@email.at> admin
invenio access allow superuser-access user <your@email.at>
"
```

`superuser-access` is required for full admin panel access and community management.

---

## 4. Roles

### 4.1 Create all roles

Run once per cluster setup (roles persist in the database):

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio roles create Marc21Curator
invenio roles create Marc21Manager
invenio roles create Marc21Creator
invenio roles create oer_curator
invenio roles create administration-rdm-records-curation
invenio roles create tugraz_authenticated
"
```

> If a role already exists you will see a `UniqueViolation` error — this is harmless, the role is already there.

### 4.2 Assign roles to a user

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio roles add <your@email.at> admin
invenio roles add <your@email.at> Marc21Curator
invenio roles add <your@email.at> Marc21Manager
invenio roles add <your@email.at> Marc21Creator
invenio roles add <your@email.at> oer_curator
invenio roles add <your@email.at> administration-rdm-records-curation
"
```

| Role | Purpose |
|------|---------|
| `admin` | Access to the administration panel |
| `Marc21Curator` | Curate Marc21 (publication) records |
| `Marc21Manager` | Manage Marc21 records |
| `Marc21Creator` | Create Marc21 records |
| `oer_curator` | Curate OER / LOM (educational resource) records |
| `administration-rdm-records-curation` | Curate RDM records in the admin panel |
| `tugraz_authenticated` | Assigned automatically to TU Graz SSO users |

---

## 5. Demo Records

Use demo records to populate the system for testing. All commands run inside the web pod.

### 5.1 RDM records (standard research data)

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio rdm-records fixtures
invenio rdm-records demo records -u <your@email.at> -r 20
"
```

- `fixtures` loads vocabularies, OAI sets, etc. — run once, skip if already done
- `-r 20` creates 20 demo records

### 5.2 Marc21 records (publications)

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio marc21 demo -u <your@email.at> -n 10
"
```

- `-n 10` creates 10 demo publications

### 5.3 LOM records (educational resources / OER)

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio lom demo -n 10
"
```

- `-n 10` creates 10 demo OER records
- Note: `lom demo` does not support `-u`, records are created under the system default user

---

## 6. Global Search

Global search allows users to search across all resource types (RDM records, publications, OER) from a single search bar.

### 6.1 How it works

InvenioRDM uses `invenio-global-search` to federate search across multiple record types. Each resource type (RDM records, Marc21, LOM) registers itself as a search source. The search bar dropdown shows all registered sources.

### 6.2 Rebuild global search (run after every new deployment)

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio global-search rebuild-database
"
```

This re-registers all configured resource types in the database. **Run this whenever:**
- A new web pod is deployed
- A new resource type is added
- The search dropdown is missing resource types

### 6.3 Rebuild all search indices

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio rdm rebuild-all-indices
"
```

This reindexes all records into OpenSearch. **Run this when:**
- Records are not appearing in search results
- After a fresh deployment
- After bulk data imports

### 6.4 Full rebuild (global search + all indices)

```bash
kubectl exec <WEB_POD> -- bash -c "
invenio global-search rebuild-database
invenio rdm rebuild-all-indices
"
```

---

## 7. Full Setup Sequence (new deployment)

Run this after every fresh deployment in order:

```bash
WEB_POD=$(kubectl get pod --no-headers -o custom-columns=':metadata.name' | grep inveniordm-web)

# 1. Create roles (safe to re-run, duplicates are ignored)
kubectl exec $WEB_POD -- bash -c "
invenio roles create Marc21Curator
invenio roles create Marc21Manager
invenio roles create Marc21Creator
invenio roles create oer_curator
invenio roles create administration-rdm-records-curation
invenio roles create tugraz_authenticated
"

# 2. Assign roles and superuser access (replace <your@email.at> with your SSO email)
kubectl exec $WEB_POD -- bash -c "
invenio roles add <your@email.at> admin
invenio roles add <your@email.at> Marc21Curator
invenio roles add <your@email.at> Marc21Manager
invenio roles add <your@email.at> Marc21Creator
invenio roles add <your@email.at> oer_curator
invenio roles add <your@email.at> administration-rdm-records-curation
invenio access allow superuser-access user <your@email.at>
"

# 3. Load fixtures (skip if already done)
kubectl exec $WEB_POD -- bash -c "invenio rdm-records fixtures"

# 4. Rebuild global search and indices
kubectl exec $WEB_POD -- bash -c "
invenio global-search rebuild-database
invenio rdm rebuild-all-indices
"
```

---

## 8. Useful Commands

```bash
# Get a shell inside the web pod
kubectl exec -it <WEB_POD> -- bash

# Check logs of the web pod
kubectl logs <WEB_POD> -c web --tail=100

# Check worker logs
kubectl logs <WEB_POD_WORKER> --tail=100

# Rebuild only the LOM index
kubectl exec <WEB_POD> -- bash -c "invenio lom rebuild-index"

# Rebuild only the Marc21 index
kubectl exec <WEB_POD> -- bash -c "invenio index reindex --pid-type marc21_record"
```

---
