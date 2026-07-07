# SPDX-FileCopyrightText: 2026 Graz University of Technology.

from invenio_db import db
from sqlalchemy import text


def update_alembic_version_table(connection):
    """Update alembic version table."""

    connection.execute(
        text(
            "UPDATE alembic_version "
            "SET version_num='c39b06b59667' "
            "WHERE version_num='';"
        )
    )
    connection.execute(
        text(
            "DELETE FROM alembic_version WHERE version_num='201faeb649c7';"  # webhooks is not more in use, so these HEADs should be removed
        )
    )
    connection.execute(
        text(
            "DELETE FROM alembic_version WHERE version_num='2f62e6442a08';"  # github is not more in use, so these HEADs should be removed
        )
    )
    connection.execute(
        text(
            "DELETE FROM alembic_version WHERE version_num='1757597048';"  # clean up invenio-jobs
        )
    )
    connection.execute(
        text(
            "DELETE FROM alembic_version WHERE version_num='9732b5f7609a';"  # clean up invenio-jobs
        )
    )

    connection.execute(
        text(
            "DELETE FROM rdm_drafts_files WHERE id='23ace3c2-876a-4fc5-802d-c5b86189b161';"  # clean up for uidx_rdm_drafts_files_record_id_key
        )
    )

    connection.execute(
        text(
            "INSERT INTO alembic_version (version_num) VALUES ('f9843093f686');"  # set head of invenio-access
        )
    )


if __name__ == "__main__":
    with db.engine.connect() as connection:
        with connection.begin():
            update_alembic_version_table(connection)
