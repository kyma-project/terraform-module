mock_provider "btp" {}

variables {
  globalaccount         = "test"
  BTP_USE_SUBACCOUNT_ID = "869662fd-2c14-42fb-b622-5a33c89cf2b9"
}

run "empty_custom_oidc" {
  command = plan

  assert {
    condition     = var.BTP_KYMA_CUSTOM_OIDC == null
    error_message = "The variable BTP_KYMA_CUSTOM_OIDC was not null."
  }
}

run "valid_minimal_custom_oidc" {
  command = plan

  variables {
    BTP_KYMA_CUSTOM_OIDC = {
      clientID       = "my-client-id"
      issuerURL      = "https://example.com/oidc"
      usernameClaim  = ""
      usernamePrefix = ""
      groupsClaim    = ""
      signingAlgs    = []
      requiredClaims = []
    }
  }

  assert {
    condition     = var.BTP_KYMA_CUSTOM_OIDC != null
    error_message = "The variable BTP_KYMA_CUSTOM_OIDC was not set."
  }
}

run "invalid_custom_oidc_noclientid" {
  command = plan

  variables {
    BTP_KYMA_CUSTOM_OIDC = {
      clientID       = ""
      issuerURL      = "https://example.com/oidc"
      usernameClaim  = ""
      usernamePrefix = ""
      groupsClaim    = ""
      signingAlgs    = []
      requiredClaims = []
    }
  }

  expect_failures = [var.BTP_KYMA_CUSTOM_OIDC.clientID]
}

run "invalid_custom_oidc_noissuerurl" {
  command = plan

  variables {
    BTP_KYMA_CUSTOM_OIDC = {
      clientID       = "my-client-id"
      issuerURL      = ""
      usernameClaim  = ""
      usernamePrefix = ""
      groupsClaim    = ""
      signingAlgs    = []
      requiredClaims = []
    }
  }

  expect_failures = [var.BTP_KYMA_CUSTOM_OIDC.issuerURL]
}
