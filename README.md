# instance

Welcome to your InvenioRDM instance.

## Getting started

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
| ``Pipfile`` | Python requirements installed via [pipenv](https://pipenv.pypa.io) |
| ``Pipfile.lock`` | Locked requirements (generated on first install). |
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
| ``Dockerfile`` | Dockerfile used to build base image, without theme. - no variant, used for local testing. |
| ``Dockerfile.mug`` | Dockerfile used to build MUG image. (with Publications) - variant **mug** | 
| ``Dockerfile.oer`` | Dockerfile used to build Educational Resources image (OER). - variant **oer** |
| ``Dockerfile.basic`` | Dockerfile used to base invenio-override image (no OER or Publications) and also base invenio theme (without invenio-override) - variants **basic** and **vanilla** |


## CI/CD

There are 2 workflows implemented now. The main goal is CI so that the end result of these workflows is a fully functional and deployed instance image, whenever triggered.

- **build and push docker image**
  - This workflow runs automatically on every commit to the main branch and whenever a new tag is created for the repository. Additionally, it can be triggered manually from the Actions tab under 'Run workflow,' where you can select a different branch. This process results in the creation of a new Docker image, tagged with the branch name or the tag name.

 - **deploy**
   - runs when **build and push docker image** is completed
   - triggers Gitlab pipeline with the current docker image tags which will handle the actual deployment of the newly created images 
  
  
