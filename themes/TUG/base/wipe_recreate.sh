#!/usr/bin/env sh
# -*- coding: utf-8 -*-
#
# Copyright (C) 2020 - 2021 CERN.
# Copyright (C) 2020 - 2026 Graz University of Technology.
#
# keep this file in sync with:
# https://github.com/inveniosoftware/demo-inveniordm/blob/master/demo-inveniordm/wipe_recreate.sh
#

# ======================================
# Shell options
# ======================================

# Quit on errors
set -o errexit

# Quit on unbound symbols
set -o nounset

# Wait for all services to be up and running
sleep 5

# ======================================
# Wipe
# ======================================

invenio shell --no-term-title -c "import redis; redis.StrictRedis.from_url(app.config['CACHE_REDIS_URL']).flushall(); print('Cache cleared')"
# db destroy is not needed since DB keeps being created — just drop all tables
invenio db drop --yes-i-know
invenio index destroy --force --yes-i-know
invenio index queue init purge

# ======================================
# Recreate
# ======================================

# db init is not needed since DB keeps being created — just recreate all tables
invenio db create
# TODO: add back when pipenv access problem is fixed
#invenio files location create --default 'default-location'  $(pipenv run invenio shell --no-term-title -c "print(app.instance_path)")'/data'
invenio files location create --default 'default-location' /opt/invenio/var/instance/data
invenio roles create admin
invenio access allow superuser-access role admin
invenio index init --force
invenio rdm-records custom-fields init
invenio communities custom-fields init

# ======================================
# Fixtures
# ======================================

invenio rdm-records fixtures

# ======================================
# Roles and users
# ======================================

invenio roles create oer_curator
invenio roles create Marc21Curator
invenio roles create Marc21Manager
invenio roles create administration-rdm-records-curation
# Add tugraz_authenticated role — assigned after SAML login is acknowledged
invenio roles create tugraz_authenticated

invenio users create admin-v2@demo.org --password 123456 --active --confirm
invenio roles add admin-v2@demo.org admin
invenio roles add admin-v2@demo.org oer_curator
invenio roles add admin-v2@demo.org Marc21Curator
invenio roles add admin-v2@demo.org Marc21Manager
invenio roles add admin-v2@demo.org administration-rdm-records-curation

# ======================================
# Optional / disabled steps
# ======================================

# Connector test accounts (disabled)
# invenio users create alma@tugraz.at --password 123456 --active --confirm
# invenio users create imoox@tugraz.at --password 123456 --active --confirm
# invenio users create cms@tugraz.at --password 123456 --active --confirm

# Demo records — disabled due to out-of-sync fixtures
# see: https://github.com/inveniosoftware/demo-inveniordm/commit/ced044a27059f22c8bc48e5d79e06441436a2ad7
# invenio rdm-records demo
# invenio marc21 demo
# invenio lom demo

# Vocabulary imports — deprecated
# invenio vocabularies import languages licenses
# invenio vocabularies import --vocabulary awards --origin "app_data/vocabularies/awards_sample.tar"

# Enable admin user
# invenio users activate admin@inveniosoftware.org