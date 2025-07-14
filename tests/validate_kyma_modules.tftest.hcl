mock_provider "btp" {}

variables {
  globalaccount         = "test"
  BTP_USE_SUBACCOUNT_ID = "869662fd-2c14-42fb-b622-5a33c89cf2b9"
}

run "valid_kyma_modules" {
  command = plan

  variables {
    BTP_KYMA_MODULES = [
      {
        name    = "application-connector"
        channel = "regular"
      },
      {
        name    = "keda"
        channel = "fast"
      }
    ]
  }
  assert {
    condition     = length(var.BTP_KYMA_MODULES) == 2
    error_message = "The variable BTP_KYMA_MODULES was not set correctly (expected 2 entries)."
  }
}

run "invalid_kyma_module_name" {
  command = plan

  variables {
    BTP_KYMA_MODULES = [
      {
        name    = "fancy-kyma-module"
        channel = "regular"
      },
      {
        name    = "keda"
        channel = "fast"
      }
    ]
  }
  expect_failures = [
    var.BTP_KYMA_MODULES[0].name
  ]
}

run "invalid_kyma_module_channel" {
  command = plan

  variables {
    BTP_KYMA_MODULES = [
      {
        name    = "application-connector"
        channel = "regular"
      },
      {
        name    = "keda"
        channel = "insider"
      }
    ]
  }
  expect_failures = [
    var.BTP_KYMA_MODULES[1].name
  ]
}


run "no_kyma_modules" {
  command = plan

  variables {
    BTP_KYMA_MODULES = []
  }
  assert {
    condition     = length(var.BTP_KYMA_MODULES) == 0
    error_message = "The variable BTP_KYMA_MODULES was not set correctly (expected emtpty)."
  }
}
