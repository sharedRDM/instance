# STAGE 1
FROM ghcr.io/tu-graz-library/docker-invenio-base:main-builder-3.14 AS builder


COPY pyproject.toml uv.lock ./

RUN uv sync --frozen

# to use rspack
ENV INVENIO_WEBPACKEXT_PROJECT="invenio_assets.webpack:rspack_project"

COPY ./app_data/ ${INVENIO_INSTANCE_PATH}/app_data/
COPY ./assets/ ${INVENIO_INSTANCE_PATH}/assets/
# copy specific assets
COPY ./themes/vanilla/assets/js ${INVENIO_INSTANCE_PATH}/assets/js
COPY ./static/ ${INVENIO_INSTANCE_PATH}/static/
COPY ./translations ${INVENIO_INSTANCE_PATH}/translations/
COPY ./themes/vanilla/templates ${INVENIO_INSTANCE_PATH}/templates/

RUN invenio collect --verbose && invenio webpack create

WORKDIR ${INVENIO_INSTANCE_PATH}/assets
RUN pnpm install
RUN pnpm run build


# STAGE 2
FROM ghcr.io/tu-graz-library/docker-invenio-base:main-frontend-3.14 AS frontend

ENV PATH=/opt/env/bin:$PATH


COPY --from=builder ${UV_PROJECT_ENVIRONMENT}/lib ${UV_PROJECT_ENVIRONMENT}/lib
COPY --from=builder ${UV_PROJECT_ENVIRONMENT}/bin ${UV_PROJECT_ENVIRONMENT}/bin
COPY --from=builder ${INVENIO_INSTANCE_PATH}/app_data ${INVENIO_INSTANCE_PATH}/app_data
COPY --from=builder ${INVENIO_INSTANCE_PATH}/static ${INVENIO_INSTANCE_PATH}/static
COPY --from=builder ${INVENIO_INSTANCE_PATH}/translations ${INVENIO_INSTANCE_PATH}/translations
COPY --from=builder ${INVENIO_INSTANCE_PATH}/templates ${INVENIO_INSTANCE_PATH}/templates

WORKDIR ${WORKING_DIR}/src

COPY ./docker/uwsgi/ ${INVENIO_INSTANCE_PATH}
COPY ./invenio.cfg ${INVENIO_INSTANCE_PATH}
RUN chown invenio:invenio .

USER invenio

ENTRYPOINT [ "bash", "-c"]
ENTRYPOINT [ "bash", "-c"]
