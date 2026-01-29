// This file is part of InvenioRDM
// Copyright (C) 2023 CERN.
//
// Invenio App RDM is free software; you can redistribute it and/or modify it
// under the terms of the MIT License; see LICENSE file for more details.

/**
 * Curation component overrides for InvenioRDM.
 * These are imported and bundled from invenio-override package.
 */

// Import curation components from invenio-override's bundle
// (which includes the full implementation with invenio-curations)
import { DepositBox } from "@js/invenio_curations/deposit/DepositBox";
import { curationComponentOverrides } from "@js/invenio_curations/requests";

export const overriddenComponents = {
  ...curationComponentOverrides,
  "InvenioAppRdm.Deposit.CardDepositStatusBox.container": DepositBox,
};
