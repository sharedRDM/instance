
# Docker remove all images 
docker system prune -a --volumes -f

uv run invenio-cli services destroy

# fresh venv + deps
rm -rf .venv
uv venv --prompt uv-env
source .venv/bin/activate
uv sync

# env once
export INVENIO_SQLALCHEMY_DATABASE_URI="postgresql+psycopg2://instance:instance@localhost/instance"

# start services
uv run invenio-cli services setup

# create tables + index
uv run invenio db create
uv run invenio index init
uv run invenio rdm-records fixtures


# create curator role and assign
uv run invenio roles create administration-rdm-records-curation
uv run invenio roles add admin-v2@demo.org administration-rdm-records-curation

# rebuild index if needed
uv run invenio rdm-records rebuild-index

# run app
uv run invenio-cli run


export DOCKER_DEFAULT_PLATFORM=linux/amd64

# build fresh image
docker build --no-cache --platform=linux/amd64 -f Dockerfile.mug -t instance-mug-test:local ..

# start full stack with the new image
DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose -f docker-compose.full.yml up -d --build

# run setup inside web-ui container
docker compose -f docker-compose.full.yml exec web-ui invenio db create
docker compose -f docker-compose.full.yml exec web-ui invenio index init
docker compose -f docker-compose.full.yml exec web-ui invenio rdm-records fixtures
docker compose -f docker-compose.full.yml exec web-ui invenio roles create administration-rdm-records-curation
docker compose -f docker-compose.full.yml exec web-ui invenio roles add admin-v2@demo.org administration-rdm-records-curation
docker compose -f docker-compose.full.yml exec web-ui invenio rdm-records rebuild-index