# we're using uppercase variable names, since in some cases (e.g Azure DevOps) the system variables are forced to be uppercase
# TF allows providing variable values as env variables of name name, case sensitive

variable "BTP_BACKEND_URL" {
  type        = string
  description = "Backend URL for the BTP CLI server. Defaults to https://cli.btp.cloud.sap"
  default     = "https://cli.btp.cloud.sap"
}


variable "BTP_USE_SUBACCOUNT_ID" {
  type        = string
  description = "ID of the subaccount to be used for the Kyma cluster"
  default     = null
}

variable "BTP_NEW_SUBACCOUNT_NAME" {
  type        = string
  description = "Name of the new subaccount for the Kyma cluster"
  default     = null
  validation {
    condition     = var.BTP_USE_SUBACCOUNT_ID != null || var.BTP_NEW_SUBACCOUNT_NAME != null
    error_message = "The value of BTP_NEW_SUBACCOUNT_NAME must be set if BTP_USE_SUBACCOUNT_ID is not provided."
  }
}

variable "BTP_NEW_SUBACCOUNT_REGION" {
  type        = string
  description = "Region for the subaccount where the Kyma environment is created"
  default     = "eu20"
  validation {
    condition     = var.BTP_USE_SUBACCOUNT_ID != null || var.BTP_NEW_SUBACCOUNT_REGION != null
    error_message = "The value of BTP_NEW_SUBACCOUNT_REGION must be set if BTP_USE_SUBACCOUNT_ID is not provided."
  }
}

variable "BTP_KYMA_PLAN" {
  type        = string
  description = "Plan name of the Kyma environment."
  default     = "azure"
  validation {
    condition     = contains(["aws", "azure", "gcp", "azure-lite"], var.BTP_KYMA_PLAN)
    error_message = "The value of BTP_KYMA_PLAN must be one of: aws, azure, gcp, azure-lite."
  }
}

variable "BTP_KYMA_REGION" {
  type        = string
  description = "Region of your Kyma Cluster"
  default     = "westeurope"
  validation {
    condition = (
      var.BTP_KYMA_PLAN == "aws" ? contains([
        "eu-central-1", "eu-west-2", "ca-central-1", "sa-east-1", "us-east-1", "ap-northeast-1", "ap-northeast-2", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "us-west-2"
      ], var.BTP_KYMA_REGION) :
      var.BTP_KYMA_PLAN == "gcp" ? contains([
        "europe-west", "asia-south1", "us-central1", "asia-northeast2", "me-central2", "me-west1", "australia-southeast1", "southamerica-east1", "asia-northeast1", "asia-southeast1", "us-west1", "us-east4"
      ], var.BTP_KYMA_REGION) :
      contains(["azure", "azure-lite"], var.BTP_KYMA_PLAN) ? contains([
        "eastus", "centralus", "westus2", "uksouth", "northeurope", "westeurope", "japaneast", "southeastasia", "australiaeast", "switzerlandnorth", "brazilsouth", "canadacentral"
      ], var.BTP_KYMA_REGION) : true
    )
    error_message = "The value of BTP_KYMA_REGION is not valid for the selected BTP_KYMA_PLAN."
  }
}

variable "BTP_KYMA_AUTOSCALER_MIN" {
  description = "Minimum number of virtual machines created in the Kyma environment."
  type        = number
  default     = 3
  validation {
    condition = contains(["aws", "azure", "gcp"], var.BTP_KYMA_PLAN) ? (
      var.BTP_KYMA_AUTOSCALER_MIN >= 3 && var.BTP_KYMA_AUTOSCALER_MIN <= var.BTP_KYMA_AUTOSCALER_MAX
      ) : (
      var.BTP_KYMA_PLAN == "azure-lite" ? (
        var.BTP_KYMA_AUTOSCALER_MIN >= 2 && var.BTP_KYMA_AUTOSCALER_MIN <= var.BTP_KYMA_AUTOSCALER_MAX
      ) : true
    )
    error_message = "The value of BTP_KYMA_AUTOSCALER_MIN must be between 3 and BTP_KYMA_AUTOSCALER_MAX if BTP_KYMA_PLAN is aws, azure, or gcp; or between 2 and BTP_KYMA_AUTOSCALER_MAX if plan is azure-lite."
  }
}

variable "BTP_KYMA_AUTOSCALER_MAX" {
  description = "Maximum number of virtual machines created in the Kyma environment."
  type        = number
  default     = 10
  validation {
    condition = contains(["aws", "azure", "gcp"], var.BTP_KYMA_PLAN) ? (
      var.BTP_KYMA_AUTOSCALER_MAX >= 3 && var.BTP_KYMA_AUTOSCALER_MAX <= 300 && var.BTP_KYMA_AUTOSCALER_MAX >= var.BTP_KYMA_AUTOSCALER_MIN
      ) : (
      var.BTP_KYMA_PLAN == "azure-lite" ? (
        var.BTP_KYMA_AUTOSCALER_MAX >= 2 && var.BTP_KYMA_AUTOSCALER_MAX <= 40 && var.BTP_KYMA_AUTOSCALER_MAX >= var.BTP_KYMA_AUTOSCALER_MIN
      ) : true
    )
    error_message = "The value of BTP_KYMA_AUTOSCALER_MAX must be between 3 and 300 and >= BTP_KYMA_AUTOSCALER_MIN if BTP_KYMA_PLAN is aws, azure, or gcp; or between 2 and 40 and >= BTP_KYMA_AUTOSCALER_MIN if plan is azure-lite."
  }
}

variable "BTP_KYMA_CUSTOM_ADMINISTRATORS" {
  type        = list(string)
  description = "List of cluster administrators (list of email addresses) for the Kyma environment."
  default     = []
}

variable "BTP_KYMA_MODULES" {
  type = list(object({
    name    = string
    channel = string
  }))
  default     = []
  description = "The list of Kyma modules to install. You can specify the name and channel for each module."
  validation {
    condition = alltrue([
      for m in var.BTP_KYMA_MODULES :
      contains([
        "application-connector", "cloud-manager", "eventing", "keda", "nats", "serverless", "telemetry", "transparent-proxy", "connectivity-proxy"
      ], m.name) && contains(["regular", "fast"], m.channel)
    ])
    error_message = "Each module 'name' must be one of: application-connector, cloud-manager, eventing, keda, nats, serverless, telemetry, transparent-proxy, connectivity-proxy. Each 'channel' must be either 'regular' or 'fast'."
  }
}

variable "BTP_KYMA_CUSTOM_OIDC" {
  description = "Custom OIDC configuration for the Kyma environment."
  type = object({
    clientID       = string
    issuerURL      = string
    usernameClaim  = string
    usernamePrefix = string
    groupsClaim    = string
    signingAlgs    = list(string)
    requiredClaims = list(string)
  })
  default = null
  validation {
    condition     = var.BTP_KYMA_CUSTOM_OIDC == null || (length(trim(var.BTP_KYMA_CUSTOM_OIDC.clientID)) > 0 && length(trim(var.BTP_KYMA_CUSTOM_OIDC.issuerURL)) > 0)
    error_message = "If the variable BTP_KYMA_CUSTOM_OIDC is provided, both clientID and issuerURL must be set and non-empty."
  }
}

variable "BTP_KYMA_SETUP_TIMEOUTS" {
  description = "Timeouts for the Kyma environment setup."
  type        = map(string)
  default = {
    create = "60m"
    update = "30m"
    delete = "60m"
  }
}
