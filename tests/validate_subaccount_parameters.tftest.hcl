mock_provider "btp" {}

variables {
  globalaccount = "test"
}

run "valid_existing_subaccount" {
  command = plan

  variables {
    BTP_USE_SUBACCOUNT_ID = "869662fd-2c14-42fb-b622-5a33c89cf2b9"
  }
  assert {
    condition     = var.BTP_USE_SUBACCOUNT_ID == "869662fd-2c14-42fb-b622-5a33c89cf2b9"
    error_message = "The variable BTP_USE_SUBACCOUNT_ID was not set correctly."
  }
}

run "valid_new_subaccount" {
  command = plan

  variables {
    BTP_NEW_SUBACCOUNT_NAME   = "test-subaccount"
    BTP_NEW_SUBACCOUNT_REGION = "eu21"
  }
  assert {
    condition     = var.BTP_NEW_SUBACCOUNT_NAME == "test-subaccount" && var.BTP_NEW_SUBACCOUNT_REGION == "eu21" && var.BTP_USE_SUBACCOUNT_ID == null
    error_message = "The variable BTP_NEW_SUBACCOUNT_NAME or BTP_NEW_SUBACCOUNT_REGIONwas not set correctly."
  }
}


run "invalid_no_subaccount_settings" {
  command = plan

  // Failure is raised at validation of var.BTP_NEW_SUBACCOUNT_NAME
  expect_failures = [var.BTP_NEW_SUBACCOUNT_NAME]
}


run "invalid_missing_subaccount_region" {
  command = plan

  variables {
    BTP_NEW_SUBACCOUNT_NAME   = "test-subaccount"
    BTP_NEW_SUBACCOUNT_REGION = null
  }
  expect_failures = [
    var.BTP_NEW_SUBACCOUNT_REGION
  ]
}

run "invalid_missing_subaccount_name" {
  command = plan

  variables {
    BTP_NEW_SUBACCOUNT_REGION = "eu21"
  }
  expect_failures = [
    var.BTP_NEW_SUBACCOUNT_NAME
  ]
}
