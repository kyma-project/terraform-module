terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = ">= 1.6.0"
    }
    http = {
      source = "hashicorp/http"
    }
    http-full = {
      source = "salrashid123/http-full"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32.0"
    }   
  }
}

provider "http" {}
provider "http-full" {}

provider "btp" {
  globalaccount = var.BTP_GLOBAL_ACCOUNT
  cli_server_url = var.BTP_BACKEND_URL
  idp            = var.BTP_CUSTOM_IAS_TENANT
  username = var.BTP_BOT_USER
  password = var.BTP_BOT_PASSWORD
}

# this shows how to configure kubernetes terraform provider with the output from terraform module for kyma
locals {
  kubeconfig = module.kyma.kubeconfig
  subaccount_id = var.BTP_USE_SUBACCOUNT_ID
  subaccount_name = data.btp_subaccount.target_subaccount.name
  oidc_config = {
    groupsClaim    = "groups"
    signingAlgs    = ["RS256"]
    usernameClaim  = "sub"
    usernamePrefix = "-"
    clientID       = jsondecode(btp_subaccount_service_binding.identity_application_binding.credentials).clientid
    issuerURL      = "https://${var.BTP_CUSTOM_IAS_TENANT}.${var.BTP_CUSTOM_IAS_DOMAIN}"
  }
}

provider "kubernetes" {
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters.0.cluster.certificate-authority-data)
  host                   = local.kubeconfig.clusters.0.cluster.server
  token                  = local.kubeconfig.users.0.user.token
}

data "btp_subaccount" "target_subaccount" {
  id = local.subaccount_id
}

# custom idp setup 
resource "btp_subaccount_entitlement" "identity" {
  subaccount_id = local.subaccount_id
  service_name  = "identity"
  plan_name     = "application"
}

data "btp_subaccount_service_plan" "identity_application" {
  depends_on    = [btp_subaccount_entitlement.identity]
  subaccount_id = local.subaccount_id
  offering_name = "identity"
  name          = "application"
}


resource "btp_subaccount_trust_configuration" "custom_idp" {
  subaccount_id     = var.BTP_USE_SUBACCOUNT_ID
  identity_provider = "${var.BTP_CUSTOM_IAS_TENANT}.${var.BTP_CUSTOM_IAS_DOMAIN}"
  name              = "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}"
}

resource "btp_subaccount_service_instance" "identity_application" {
  depends_on     = [btp_subaccount_trust_configuration.custom_idp]
  subaccount_id  = local.subaccount_id
  name           = "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app"
  serviceplan_id = data.btp_subaccount_service_plan.identity_application.id
  parameters = jsonencode({
    user-access = "public"
    oauth2-configuration = {
      grant-types = [
        "authorization_code",
        "authorization_code_pkce_s256",
        "refresh_token"
      ],
      token-policy = {
        token-validity              = 3600,
        refresh-validity            = 15552000,
        refresh-usage-after-renewal = "off",
        refresh-parallel            = 3,
        access-token-format         = "default"
      },
      public-client = true,
      redirect-uris = [
        "https://dashboard.kyma.cloud.sap",
        "https://dashboard.dev.kyma.cloud.sap",
        "https://dashboard.stage.kyma.cloud.sap",
        "http://localhost:8000"
      ]
    },
    subject-name-identifier = {
      attribute          = "mail",
      fallback-attribute = "none"
    },
    default-attributes = null,
    assertion-attributes = {
      email      = "mail",
      groups     = "companyGroups",
      first_name = "firstName",
      last_name  = "lastName",
      login_name = "loginName",
      mail       = "mail",
      scope      = "companyGroups",
      user_uuid  = "userUuid",
      locale     = "language"
    },
    name         = "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app",
    display-name = "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app"
  })
}

resource "btp_subaccount_service_binding" "identity_application_binding" {
  subaccount_id       = local.subaccount_id
  name                =  "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app-binding"
  service_instance_id = btp_subaccount_service_instance.identity_application.id
  parameters = jsonencode({
    credential-type = "X509_GENERATED"
    key-length      = 4096
    validity        = 1
    validity-type   = "DAYS"
    app-identifier  = "kymaruntime"
  })
}


module "kyma" {
  depends_on = [
    btp_subaccount_service_binding.identity_application_binding
  ]
  source = "../.."
  BTP_KYMA_PLAN = var.BTP_KYMA_PLAN
  BTP_USE_SUBACCOUNT_ID = var.BTP_USE_SUBACCOUNT_ID
  BTP_KYMA_CUSTOM_OIDC = local.oidc_config
  BTP_KYMA_CUSTOM_ADMINISTRATORS = var.BTP_KYMA_CUSTOM_ADMINISTRATORS 
  BTP_KYMA_REGION = var.BTP_KYMA_REGION
  BTP_KYMA_MODULES = var.BTP_KYMA_MODULES
}

output "subaccount_id" {
  value = module.kyma.subaccount_id
}

output "service_instance_id" {
  value = module.kyma.service_instance_id
}

output "cluster_id" {
  value = module.kyma.cluster_id
}

output "domain" {
  value = module.kyma.domain
}

# this shows how to use kubernetes terraform provider to read data from k8s cluster
data "kubernetes_namespace" "default" {
  depends_on = [
    module.kyma.kubeconfig
  ]
  metadata {
    name = "default"
  }
}