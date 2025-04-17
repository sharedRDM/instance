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

Update your pyproject.toml file to include all necessary dependencies

```bash
dependencies = [
    "invenio-override ~=0.0.3"
]
```

### **sync dependencies**

```bash
uv sync
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
run invenio-cli 
```

