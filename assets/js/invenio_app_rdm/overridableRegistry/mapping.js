// This file is part of InvenioRDM
// Copyright (C) 2023 CERN.
//
// Invenio App RDM is free software; you can redistribute it and/or modify it
// under the terms of the MIT License; see LICENSE file for more details.

/**
 * Add here all the overridden components of your app.
 */

import { curationComponentOverrides } from "@js/invenio_curations/requests";
import { DepositBox } from "@js/invenio_curations/deposit/DepositBox";

export const overriddenComponents = {
        // ... after your other overrides ...
        ...curationComponentOverrides,
        "InvenioAppRdm.Deposit.CardDepositStatusBox.container": DepositBox,
}