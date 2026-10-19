# -*- coding: utf-8 -*-
#
# Copyright (C) 2020-2026 Graz University of Technology.
#
# instance is free software; you can redistribute it and/or
# modify it under the terms of the MIT License; see LICENSE file for more
# details.

"""Additional views."""

from urllib.parse import urlencode

from flask import Blueprint, current_app, g, redirect, render_template, request
from invenio_i18n import lazy_gettext as _
from invenio_i18n.proxies import current_i18n
from invenio_vocabularies.proxies import current_service as vocabulary_service

# Advanced search form. Builds a query from the fields below and redirects to
# the search results. Override the fields with the ADVANCED_SEARCH_FIELDS config.

DEFAULT_ADVANCED_SEARCH_FIELDS = [
    {
        "name": "title",
        "label": _("Title"),
        "kind": "text",
        "query": "metadata.title",
        "placeholder": _("e.g. deep learning"),
    },
    {
        "name": "author",
        "label": _("Author / Creator"),
        "kind": "text",
        "query": "metadata.creators.person_or_org.name",
        "placeholder": _("e.g. Smith"),
    },
    {
        "name": "abstract",
        "label": _("Abstract / Description"),
        "kind": "text",
        "query": "metadata.description",
    },
    {
        "name": "keywords",
        "label": _("Keywords / Subject"),
        "kind": "text",
        "query": "metadata.subjects.subject",
        "placeholder": _("e.g. machine learning"),
    },
    {
        "name": "date",
        "label": _("Publication date"),
        "kind": "daterange",
        "query": "metadata.publication_date",
    },
    {
        "name": "resource_type",
        "label": _("Resource type"),
        "kind": "select",
        "query": "metadata.resource_type.id",
        "vocabulary": "resourcetypes",
    },
    {
        "name": "license",
        "label": _("License"),
        "kind": "select",
        "query": "metadata.rights.id",
        "vocabulary": "licenses",
    },
    {
        "name": "funder",
        "label": _("Funder"),
        "kind": "text",
        "query": "metadata.funding.funder.name",
        "placeholder": _("e.g. European Commission"),
    },
]


def _fields():
    """Return the configured advanced-search field definitions."""
    return current_app.config.get(
        "ADVANCED_SEARCH_FIELDS", DEFAULT_ADVANCED_SEARCH_FIELDS
    )


def _quote(value):
    """Quote a user value as a Lucene phrase, escaping backslash and quote."""
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def build_query(args, fields):
    """Build an InvenioRDM query string from the submitted fields."""
    clauses = []

    for field in fields:
        kind = field["kind"]

        if kind in ("text", "select"):
            value = (args.get(field["name"]) or "").strip()
            if value:
                token = value if kind == "select" else _quote(value)
                clauses.append(f"{field['query']}:{token}")

        elif kind == "daterange":
            date_from = (args.get(field["name"] + "_from") or "").strip()
            date_to = (args.get(field["name"] + "_to") or "").strip()
            if date_from or date_to:
                clauses.append(
                    f"{field['query']}:" f"[{date_from or '*'} TO {date_to or '*'}]"
                )

    return " AND ".join(clauses)


def _vocabulary_options(vocabulary_type):
    """Load a vocabulary as (id, label) pairs for a dropdown."""
    try:
        result = vocabulary_service.read_all(
            g.identity,
            fields=["id", "title"],
            type=vocabulary_type,
            max_records=500,
        )
        language = current_i18n.language
        items = []
        for hit in result.to_dict()["hits"]["hits"]:
            title = hit.get("title") or {}
            label = (
                title.get(language)
                or title.get("en")
                or next(iter(title.values()), hit["id"])
            )
            items.append((hit["id"], label))
        return sorted(items, key=lambda item: item[1].lower())
    except Exception:
        # the field falls back to no options
        current_app.logger.exception("Loading vocabulary %s failed", vocabulary_type)
        return []


def advanced_search():
    """Render the advanced-search form, or build the query and go to results."""
    fields = _fields()

    if request.args.get("submitted"):
        query = build_query(request.args, fields)
        target = current_app.config.get("ADVANCED_SEARCH_TARGET", "/records/search")
        if query:
            target = target + "?" + urlencode({"q": query})
        return redirect(target)

    options = {
        field["name"]: _vocabulary_options(field["vocabulary"])
        for field in fields
        if field["kind"] == "select"
    }

    return render_template(
        "instance/advanced_search.html",
        fields=fields,
        options=options,
    )


def create_blueprint(app):
    """Register the blueprint routes."""
    blueprint = Blueprint(
        "instance",
        __name__,
        template_folder="./templates",
    )

    blueprint.add_url_rule("/search/advanced", "advanced_search", advanced_search)

    return blueprint
