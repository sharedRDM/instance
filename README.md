# instance

Welcome to your InvenioRDM instance.

## Version
This repository is based on InvenioRDM v14. The exact pinned version lives in
``pyproject.toml`` / ``uv.lock``.

## Getting started

Make sure you have **invenio-cli** package installed.

### Start the instance (development)

Run the following commands to have the instance ready for development:
```bash
uv sync # this installs all packages based on your pyproject.toml dependencies
# or
uv sync --extra tug # if you want to specify optional packages (basic, tug, mug)
invenio-cli install symlink
invenio-cli services setup

# then in 2 different terminals
invenio-cli run worker # 1 terminal
invenio-cli run web # 1 terminal

# for UI dev
invenio-cli assets watch # run this to have the UI change done automatically in the running app
```

### Run a theme locally (default / TUG / MUG)

The instance ships several looks. `local_theme.sh` does locally what the
Dockerfiles do for the images: install that theme's `invenio.cfg`, swap the
theme files into the collected assets and build.

```bash
uv sync --extra basic && ./local_theme.sh default   # core InvenioRDM look, with our theme on top
uv sync --extra tug   && ./local_theme.sh TUG       # TU Graz
uv sync --extra mug   && ./local_theme.sh MUG       # Med Uni Graz

invenio-cli run
```

| Theme | Config | Look |
|---|---|---|
| ``default`` | ``themes/override-basic/invenio.cfg`` | ``themes/override-basic/variables.less`` |
| ``TUG`` | ``themes/TUG/dev/invenio.cfg`` | shipped by the invenio-override package |
| ``MUG`` | ``themes/MUG/invenio.cfg`` | ``themes/MUG/variables.less`` |

Good to know:

- the script **replaces** ``invenio webpack buildall`` - do not run that
  afterwards, it re-runs ``webpack create`` and undoes the theme swap
- ``uv sync`` is only needed when switching profile, not when you only edited a cfg
- if a switch looks wrong, run ``invenio webpack clean`` first: ``webpack create``
  never overwrites files it already collected
- log in with the local email/password form - the Keycloak button needs
  credentials that only exist in the deployed images
- the theme cfgs expect the database URI and search index prefix from
  environment variables in the images, so the script appends local dev values

### Start the instance (all containerized)

Run the following commands in order to start your new InvenioRDM instance:

```console
invenio-cli containers start --lock --build --setup
```

The above command first builds the application docker image and afterwards
starts the application and related services (database, Opensearch, Redis
and RabbitMQ). The build and boot process will take some time to complete,
especially the first time as docker images have to be downloaded during the
process.

Once running, visit https://127.0.0.1 in your browser.

**Note**: The server is using a self-signed SSL certificate, so your browser
will issue a warning that you will have to by-pass.

## Overview

Following is an overview of the generated files and folders:

| Name | Description |
|---|---|
| ``Dockerfile`` | Dockerfile used to build your application image. |
| ``pyproject.toml`` | Python requirements, installed via [uv](https://docs.astral.sh/uv/). Optional extras select the variant (``basic``, ``tug``, ``mug``). |
| ``uv.lock`` | Locked requirements. |
| ``local_theme.sh`` | Local dev helper to run a theme (``default``/``TUG``/``MUG``). |
| ``themes`` | Per-variant config, look and dependencies. |
| ``app_data`` | Application data such as vocabularies. |
| ``assets`` | Web assets (CSS, JavaScript, LESS, JSX templates) used in the Webpack build. |
| ``docker`` | Example configuration for NGINX and uWSGI. |
| ``docker-compose.full.yml`` | Example of a full infrastructure stack. |
| ``docker-compose.yml`` | Backend services needed for local development. |
| ``docker-services.yml`` | Common services for the Docker Compose files. |
| ``invenio.cfg`` | The Invenio application configuration. |
| ``logs`` | Log files. |
| ``static`` | Static files that need to be served as-is (e.g. images). |
| ``templates`` | Folder for your Jinja templates. |
| ``.invenio`` | Common file used by Invenio-CLI to be version controlled. |
| ``.invenio.private`` | Private file used by Invenio-CLI *not* to be version controlled. |
| ``.github/workflows`` | Folder to add or edit github workflows. |

## Documentation

To learn how to configure, customize, deploy and much more, visit
the [InvenioRDM Documentation](https://inveniordm.docs.cern.ch/).

## Working with UV

For detailed steps on working with UV, check the [Working with UV](./UV-GUIDE.md) documentation.

## Docker Images

Each image has a correspondent instance _variant_ that a user can choose to deploy.

| Name | Description |
|---|---|
| ``Dockerfile.tug`` | TU Graz image. Built twice, selected by the ``TUG_ENV`` build arg - variants **dev** and **qa** |
| ``Dockerfile.mug`` | Med Uni Graz image (Research Results and Publications) - variant **mug** |
| ``Dockerfile.basic`` | Core InvenioRDM behaviour with the invenio-override theme on top - variant **basic** |
| ``Dockerfile`` | Core InvenioRDM without any theme - variant **vanilla** |
| ``Dockerfile.oer`` | Educational Resources image (OER) - variant **oer**, not built by CI |

Every image builds from the root ``pyproject.toml``/``uv.lock`` and picks the
variant with ``uv sync --frozen --extra <basic|tug|mug>`` - the same dependencies
``local_theme.sh`` installs, so local and CI resolve the exact same package set.
Each ``themes/<variant>`` directory then only holds that variant's look
(``variables.less``/``overrides.less``), ``invenio.cfg`` and templates.


## CI/CD

The main goal is CI so that the end result of this workflow is a fully functional instance image, whenever triggered.

This repository's only workflow runs automatically on every commit to the main branch and whenever a new tag is created for the repository. Additionally, it can be triggered manually from the Actions tab under 'Run workflow,' where you can select the following
  - the invenio-override branch
  - the branch of this repository to run the workflow from.
  
This process results in the creation of 4 new Docker images, tagged with the branch name or the tag name.
