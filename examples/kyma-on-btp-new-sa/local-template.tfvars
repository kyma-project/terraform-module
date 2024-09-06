# BTP_USE_SUBACCOUNT_ID = ""

BTP_NEW_SUBACCOUNT_NAME = ""

# one of many available regions (without the `cf-` prefix!). I.e `eu20`
BTP_NEW_SUBACCOUNT_REGION = ""

BTP_BOT_USER = ""
BTP_BOT_PASSWORD = ""
BTP_GLOBAL_ACCOUNT = ""

# optional. will default to `https://cli.btp.cloud.sap`. For Canary landscape use `https://cpcli.cf.sap.hana.ondemand.com`
BTP_BACKEND_URL = ""

# Mandatory
BTP_CUSTOM_IAS_TENANT = ""
# Optional. Defaults to `accounts.ondemand.com`. For Canary landscape use `accounts400.ondemand.com`
BTP_CUSTOM_IAS_DOMAIN = ""

# Optional. defaults to `azure`; One of: `azure`, `sap-converged-cloud`, `aws`, `gcp`
BTP_KYMA_PLAN = ""
# Must match options for given plan; i.e `westeurope` is a valid kyma region for kyma plan `azure`
BTP_KYMA_REGION = ""
#optional
BTP_PROVIDER_SUBACCOUNT_ID = ""