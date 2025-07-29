mock_provider "btp" {}

variables {
  globalaccount         = "test"
  BTP_USE_SUBACCOUNT_ID = "869662fd-2c14-42fb-b622-5a33c89cf2b9"
}

run "valid_autoscaler_settings_aws" {
  command = plan

  variables {
    BTP_KYMA_PLAN           = "aws"
    BTP_KYMA_REGION         = "eu-central-1"
    BTP_KYMA_AUTOSCALER_MIN = 5
    BTP_KYMA_AUTOSCALER_MAX = 15
  }
  assert {
    condition     = var.BTP_KYMA_AUTOSCALER_MIN == 5 && var.BTP_KYMA_AUTOSCALER_MAX == 15
    error_message = "The variables for autoscaler settings were not transfered correctly."
  }
}

run "valid_autoscaler_settings_azure_lite" {
  command = plan

  variables {
    BTP_KYMA_PLAN           = "azure-lite"
    BTP_KYMA_REGION         = "uksouth"
    BTP_KYMA_AUTOSCALER_MIN = 2
    BTP_KYMA_AUTOSCALER_MAX = 39
  }
  assert {
    condition     = var.BTP_KYMA_AUTOSCALER_MIN == 2 && var.BTP_KYMA_AUTOSCALER_MAX == 39
    error_message = "The variables for autoscaler settings were not transfered correctly."
  }
}

run "invalid_min_autoscaler_settings_aws" {
  command = plan

  variables {
    BTP_KYMA_PLAN           = "aws"
    BTP_KYMA_REGION         = "eu-central-1"
    BTP_KYMA_AUTOSCALER_MIN = 2
    BTP_KYMA_AUTOSCALER_MAX = 50
  }
  expect_failures = [
    var.BTP_KYMA_AUTOSCALER_MIN
  ]
}

run "invalid_min_autoscaler_settings_azure_lite" {
  command = plan

  variables {
    BTP_KYMA_PLAN           = "azure-lite"
    BTP_KYMA_REGION         = "uksouth"
    BTP_KYMA_AUTOSCALER_MIN = 1
    BTP_KYMA_AUTOSCALER_MAX = 5
  }
  expect_failures = [
    var.BTP_KYMA_AUTOSCALER_MIN
  ]
}

run "invalid_max_autoscaler_settings_aws" {
  command = plan

  variables {
    BTP_KYMA_PLAN           = "aws"
    BTP_KYMA_REGION         = "eu-central-1"
    BTP_KYMA_AUTOSCALER_MIN = 3
    BTP_KYMA_AUTOSCALER_MAX = 400
  }
  expect_failures = [
    var.BTP_KYMA_AUTOSCALER_MAX
  ]
}

run "invalid_max_autoscaler_settings_azure_lite" {
  command = plan

  variables {
    BTP_KYMA_PLAN           = "azure-lite"
    BTP_KYMA_REGION         = "uksouth"
    BTP_KYMA_AUTOSCALER_MIN = 2
    BTP_KYMA_AUTOSCALER_MAX = 99
  }
  expect_failures = [
    var.BTP_KYMA_AUTOSCALER_MAX
  ]
}

run "invalid_min_max_autoscaler_settings_azure_lite" {
  command = plan

  variables {
    BTP_KYMA_PLAN           = "azure-lite"
    BTP_KYMA_REGION         = "uksouth"
    BTP_KYMA_AUTOSCALER_MIN = 12
    BTP_KYMA_AUTOSCALER_MAX = 5
  }
  expect_failures = [
    var.BTP_KYMA_AUTOSCALER_MAX
  ]
}
