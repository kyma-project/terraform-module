mock_provider "btp" {}

variables {
  globalaccount         = "test"
  BTP_USE_SUBACCOUNT_ID = "869662fd-2c14-42fb-b622-5a33c89cf2b9"
}

run "valid_kyma_plan_with_region" {
  command = plan

  variables {
    BTP_KYMA_PLAN   = "aws"
    BTP_KYMA_REGION = "eu-central-1"
  }
  assert {
    condition     = var.BTP_KYMA_PLAN == "aws"
    error_message = "The variable BTP_KYMA_PLAN or BTP_KYMA_REGION was not set correctly."
  }
}

run "valid_kyma_plan_with_invalid_region" {
  command = plan

  variables {
    BTP_KYMA_PLAN   = "azure"
    BTP_KYMA_REGION = "eu-central-1"
  }
  expect_failures = [
    var.BTP_KYMA_REGION
  ]
}

run "invalid_kyma_plan" {
  command = plan

  variables {
    BTP_KYMA_PLAN = "sap"
  }
  expect_failures = [
    var.BTP_KYMA_PLAN
  ]
}
