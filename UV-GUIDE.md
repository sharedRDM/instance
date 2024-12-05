## **Working with UV InvenioRDM**

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

### **3. build assets**

Compile and build assets for the project:

```bash
uv run invenio-cli assets build
```

### **4. start/destroy Services**

Set up and start required services:

```bash
uv run invenio-cli services destroy
uv run invenio-cli services setup
```

### **5. run the app**

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

### **recreating virtual env**

```bash
rm -rf .venv
uv venv --prompt invenio-v12 && source .venv/bin/activate
```

### **Notes: for services setup**

```bash
uv run invenio-cli services destroy
uv run invenio-cli services setup
```
