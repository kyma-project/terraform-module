# we're using uppercase variable names, since in some cases (e.g Azure DevOps) the system variables are forced to be uppercase
# TF allows providing variable values as env variables of name name, case sensitive

variable "BTP_KYMA_PLAN" {
  type        = string
  description = "Plan name"
  default     = "gcp"
}

variable "BTP_USE_SUBACCOUNT_ID" {
  type        = string
  description = "Subaccount name"
  default     = null
}


variable "BTP_NEW_SUBACCOUNT_NAME" {
  type        = string
  description = "Subaccount name"
  default     = null
}

variable "BTP_NEW_SUBACCOUNT_REGION" {
  type        = string
  description = "Region name"
  default     = null
}

variable "BTP_CUSTOM_IAS_TENANT" {
  type        = string
  description = "Custom IAS tenant"
  default     = "custon-tenant"
}

variable "BTP_CUSTOM_IAS_DOMAIN" {
  type        = string
  description = "Custom IAS domain"
  default     = "accounts400.ondemand.com"
}

variable "BTP_KYMA_REGION" {
  type        = string
  description = "Kyma region"
  default     = "us-central1"
}

variable "BTP_BOT_USER" {
  type        = string
  description = "Bot account name"
  default     = "email@domain.com"
}

variable "BTP_BOT_PASSWORD" {
  type        = string
  description = "Bot account password"
  default     = "password"
  sensitive = true
}

variable "BTP_PROVIDER_SUBACCOUNT_ID" {
  type        = string
  description = "Subaccount ID"
  default = null
}

variable "BTP_KYMA_MODULES" {
  type = list(object({
    name = string
    channel = string
  }))
  default = [
    {
      name = "istio"
      channel = "fast"
    },
    {
      name = "api-gateway"
      channel = "fast"
    },
    {
      name = "btp-operator"
      channel = "fast"
    }
  ]
  description = "The list of kyma modules to install"
}

