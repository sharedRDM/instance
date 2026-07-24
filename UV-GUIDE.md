## **Working with UV InvenioRDM**

### Installing UV
Make sure to [install](https://docs.astral.sh/uv/getting-started/installation) UV on your Operating system.

### **using UV to set up your virtual env and install packages**

Use UV to create and activate a virtual environment:

```bash
uv venv --prompt uv-env && source .venv/bin/activate && uv pip install -e path/to/package
uv sync
```

### **install dependencies**

Synchronize and install all dependencies:

```bash
uv pip install -e path/to/package
uv sync
```

### **define dependencies**

Base (vanilla) dependencies live in the root `pyproject.toml`:

```bash
dependencies = [
    "invenio-app-rdm[opensearch2]==14.0.0rc2",
]
```

Each theme pins its own dependencies in its own project under `themes/<variant>/`
(e.g. `themes/TUG/base`, `themes/MUG`), so instances can run different versions
independently.


### **sync dependencies**

Base venv (vanilla / bootstrap):

```bash
uv sync
```

For a theme, install from its own lock - the same one its Dockerfile builds from
(this is what `local_theme.sh` does under the hood):

```bash
uv sync --project themes/TUG/base --frozen
```

To update a theme's lock, or bump a single package:

```bash
uv lock --project themes/TUG/base
uv lock --project themes/TUG/base -P invenio-override
```


### **build assets**

Compile and build assets for the project:

```bash
uv run invenio-cli assets build
```

### **start/destroy Services**

Set up and start required services:

```bash
uv run invenio-cli services destroy
uv run invenio-cli services setup
```

### **run the app**

Start the Invenio application:

```bash
uv run invenio-cli run
```

### **OS (macOS) architecture compatibility issues**

issues related to architecture (e.g., `-84 architecture` errors) on macOS systems, particularly with Apple Silicon chips (M1/M2), use the following command to resolve them:

```bash
export SYSTEM_VERSION_COMPAT=1
arch -arm64 brew install python
```
