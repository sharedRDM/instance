// This file is part of InvenioRDM
// Copyright (C) 2023 CERN.
//
// Invenio App RDM is free software; you can redistribute it and/or modify it
// under the terms of the MIT License; see LICENSE file for more details.

/**
 * Add here all the overridden components of your app.
 */

// This file is part of InvenioRDM
// Copyright (C) 2022-2024 CERN.
//
// Invenio RDM is free software; you can redistribute it and/or modify it
// under the terms of the MIT License; see LICENSE file for more details.
// This file is part of InvenioRDM
// Copyright (C) 2021 CERN.
// Copyright (C) 2021 New York University.
// Copyright (C) 2022 data-futures.
// Copyright (C) 2023 Northwestern University.
//
// Invenio RDM Records is free software; you can redistribute it and/or modify it
// under the terms of the MIT License; see LICENSE file for more details.

import _get from "lodash/get";
import { i18next } from "@translations/invenio_app_rdm/i18next";
import React, { Component } from "react";
import Overridable from "react-overridable";
import PropTypes from "prop-types";
import { Item, Label, Icon } from "semantic-ui-react";
import { buildUID } from "react-searchkit";
import { CompactStats } from "@js/invenio_app_rdm/components/CompactStats";
import { DisplayPartOfCommunities } from "@js/invenio_app_rdm/components/DisplayPartOfCommunities";

function SearchItemCreators({ creators, className, othersLink }) {
  let spanClass = "creatibutor-wrap separated";
  className && (spanClass += ` ${className}`);

  function makeIcon(scheme, identifier, name) {
    let link = null;
    let linkTitle = null;
    let icon = null;
    let alt = "";

    switch (scheme) {
      case "orcid":
        link = `https://orcid.org/${identifier}`;
        linkTitle = i18next.t("ORCID profile");
        icon = "/static/images/orcid.svg";
        alt = "ORCID logo";
        break;
      case "ror":
        link = `https://ror.org/${identifier}`;
        linkTitle = i18next.t("ROR profile");
        icon = "/static/images/ror-icon.svg";
        alt = "ROR logo";
        break;
      case "gnd":
        link = `https://d-nb.info/gnd/${identifier}`;
        linkTitle = i18next.t("GND profile");
        icon = "/static/images/gnd-icon.svg";
        alt = "GND logo";
        break;
      default:
        return null;
    }

    icon = (
      <a
        className="no-text-decoration mr-0"
        href={link}
        aria-label={`${name}: ${linkTitle}`}
        title={`${name}: ${linkTitle}`}
        key={scheme}
      >
        <img className="inline-id-icon ml-5" src={icon} alt={alt} />
      </a>
    );
    return icon;
  }

  function getIcons(creator) {
    let ids = _get(creator, "person_or_org.identifiers", []);
    let creatorName = _get(creator, "person_or_org.name", "No name");
    let icons = ids.map((c) => makeIcon(c.scheme, c.identifier, creatorName));
    return icons;
  }

  function getLink(creator) {
    console.log("here")
    let creatorName = _get(creator, "person_or_org.name", "No name");
    let link = (
      <a
        className="creatibutor-link"
        href={`/search?q=metadata.creators:"${creatorName}"`}
        title={`${creatorName}: ${i18next.t("Search")}`}
      >
        <span className="creatibutor-name">{creatorName}</span>
      </a>
    );
    return link;
  }

  const numDisplayed = 3;
  const result = creators.slice(0, numDisplayed).map((creator) => (
    <span className={spanClass} key={creator.person_or_org.name}>
      {getLink(creator)}
      {getIcons(creator)}
    </span>
  ));

  const numExtra = creators.length - numDisplayed;
  if (0 < numExtra) {
    let text;
    if (numExtra === 1) {
      text = "and {{count}} other";
    } else {
      text = "and {{count}} others";
    }
    result.push(
      <span className={spanClass} key={text}>
        <a className="creatibutor-link" href={othersLink}>
          <span className="creatibutor-name">
            {i18next.t(text, { count: numExtra })}
          </span>
        </a>
      </span>
    );
  }

  return result;
}


class RecordsResultsListItemComponent extends Component {
  render() {
    console.log("here")
    const { currentQueryState, result, key, appName } = this.props;

    const accessStatusId = _get(result, "ui.access_status.id", "open");
    const accessStatus = _get(result, "ui.access_status.title_l10n", "Open");
    const accessStatusIcon = _get(result, "ui.access_status.icon", "unlock");
    const createdDate = _get(
      result,
      "ui.created_date_l10n_long",
      "No creation date found."
    );

    const creators = result.ui.creators.creators;

    const descriptionStripped = _get(
      result,
      "ui.description_stripped",
      "No description"
    );

    const publicationDate = _get(
      result,
      "ui.publication_date_l10n_long",
      "No publication date found."
    );
    const resourceType = _get(
      result,
      "ui.resource_type.title_l10n",
      "No resource type"
    );
    const subjects = _get(result, "ui.subjects", []);
    const title = _get(result, "metadata.title", "No title");
    const version = _get(result, "ui.version", null);
    const versions = _get(result, "versions");
    const uniqueViews = _get(result, "stats.all_versions.unique_views", 0);
    const uniqueDownloads = _get(result, "stats.all_versions.unique_downloads", 0);

    const publishingInformation = _get(result, "ui.publishing_information.journal", "");

    const filters = currentQueryState && Object.fromEntries(currentQueryState.filters);
    const allVersionsVisible = filters?.allversions;
    const numOtherVersions = versions.index - 1;

    // Derivatives
    const viewLink = `/records/${result.id}`;
    return (
        <Item key={key ?? result.id}>
          <Item.Content>
            {/* FIXME: Uncomment to enable themed banner */}
            {/* <DisplayVerifiedCommunity communities={result.parent?.communities} /> */}
            <Item.Extra className="labels-actions">
              <Label horizontal size="small" className="primary theme-primary">
                {publicationDate} ({version})
              </Label>
              <Label horizontal size="small" className="neutral">
                {resourceType}
              </Label>
              <Label
                horizontal
                size="small"
                className={`access-status ${accessStatusId}`}
              >
                {accessStatusIcon && <Icon name={accessStatusIcon} />}
                {accessStatus}
              </Label>
            </Item.Extra>
            <Item.Header as="h2" className="theme-primary-text">
              <a href={viewLink}>{title}</a>
            </Item.Header>
            <Item className="creatibutors">
              <SearchItemCreators creators={creators} othersLink={viewLink} />
            </Item>
            <Overridable
              id={buildUID("RecordsResultsListItem.description", "", appName)}
              descriptionStripped={descriptionStripped}
              result={result}
            >
              <Item.Description className="truncate-lines-2">
                {descriptionStripped}
              </Item.Description>
            </Overridable>

            <Item.Extra>
              {subjects.map((subject) => (
                <Label key={subject.title_l10n} size="tiny">
                  {subject.title_l10n}
                </Label>
              ))}

              <div className="flex justify-space-between align-items-end">
                <small>
                  <DisplayPartOfCommunities communities={result.parent?.communities} />
                  <p>
                    {createdDate && (
                      <>
                        {i18next.t("Uploaded on {{uploadDate}}", {
                          uploadDate: createdDate,
                        })}
                      </>
                    )}
                    {createdDate && publishingInformation && " | "}

                    {publishingInformation && (
                      <>
                        {i18next.t("Published in: {{- publishInfo }}", {
                          publishInfo: publishingInformation,
                        })}
                      </>
                    )}
                  </p>

                  {!allVersionsVisible && versions.index > 1 && (
                    <p>
                      <b>
                        {i18next.t("{{count}} more versions exist for this record", {
                          count: numOtherVersions,
                        })}
                      </b>
                    </p>
                  )}
                </small>

                <small>
                  <CompactStats
                    uniqueViews={uniqueViews}
                    uniqueDownloads={uniqueDownloads}
                  />
                </small>
              </div>
            </Item.Extra>
          </Item.Content>
        </Item>
    );
  }
}

RecordsResultsListItemComponent.propTypes = {
  currentQueryState: PropTypes.object,
  result: PropTypes.object.isRequired,
  key: PropTypes.string,
  appName: PropTypes.string,
};

RecordsResultsListItemComponent.defaultProps = {
  key: null,
  currentQueryState: null,
  appName: "",
};

export const RecordsResultsListItem = RecordsResultsListItemComponent;

export const overriddenComponents = {
  "RecordsResultsListItem.layout": RecordsResultsListItem,
}