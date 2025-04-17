# Fixing Cairo Library Issues on Apple Silicon (M1/M2) Macs

## Problem
When working with InvenioRDM on Apple Silicon Macs, you might encounter issues with the Cairo library, particularly when building assets. The error typically looks like:
```
OSError: no library called "cairo-2" was found
```

## Solution Steps

### 1. Install Cairo for ARM64 Architecture
```bash
arch -arm64 brew install cairo

# If Cairo is already installed, reinstall it to ensure proper ARM64 support
arch -arm64 brew reinstall cairo
```

### 2. Create Symbolic Link
```bash
sudo ln -sf /opt/homebrew/lib/libcairo.2.dylib /usr/local/lib/libcairo.2.dylib
```

### 3. Reinstall Python Packages
```bash
uv pip uninstall cairosvg cairocffi

uv pip install cairosvg cairocffi
```

### 4. Build Assets
```bash
uv run invenio-cli assets build
```

