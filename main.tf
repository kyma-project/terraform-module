# "kyma.tf"

resource "btp_subaccount_entitlement" "kyma" {
  subaccount_id = btp_subaccount.subaccount.id
  service_name  = "kymaruntime"
  plan_name     = var.BTP_KYMA_PLAN
  amount        = 1
}

resource "btp_subaccount_environment_instance" "kyma" {
  subaccount_id    = btp_subaccount.subaccount.id
  name             = "${var.BTP_SUBACCOUNT}-kyma"
  environment_type = "kyma"
  service_name     = btp_subaccount_entitlement.kyma.service_name
  plan_name        = btp_subaccount_entitlement.kyma.plan_name
  parameters = jsonencode({
    modules = {
      list = [
        {
          name    = "api-gateway"
          channel = "fast"
        },
        {
          name    = "istio"
          channel = "fast"
        },
        {
          name    = "btp-operator"
          channel = "fast"
        }
      ]
    }
    oidc = {
      groupsClaim    = "groups"
      signingAlgs    = ["RS256"]
      usernameClaim  = "sub"
      usernamePrefix = "-"
      clientID       = jsondecode(btp_subaccount_service_binding.identity_application_binding.credentials).clientid
      issuerURL      = "https://${var.BTP_CUSTOM_IAS_TENANT}.${var.BTP_CUSTOM_IAS_DOMAIN}"
    }
    name   = "${var.BTP_SUBACCOUNT}-kyma"
    region = var.BTP_KYMA_REGION
    administrators = [
      var.BTP_BOT_USER
    ]
  })
  timeouts = {
    create = "60m"
    update = "30m"
    delete = "60m"
  }
}

data "http" "kubeconfig" {
  url = jsondecode(btp_subaccount_environment_instance.kyma.labels).KubeconfigURL
  retry {
    attempts = 2
    max_delay_ms = 2000
    min_delay_ms = 1000
  }
  lifecycle {
    postcondition {
      condition     = can(regex("kind: Config",self.response_body))
      error_message = "Invalid content of downloaded kubeconfig"
    }
  }
}

locals {
  id_token = jsondecode(data.http.token.response_body).id_token
  kubeconfig_oidc = yamldecode(data.http.kubeconfig.response_body)
}

data "jq_query" "kubeconfig" {
  data = jsonencode(yamldecode(data.http.kubeconfig.response_body))
  query = "del(.users[] | .user | .exec) | .users[] |= . + { user: { token: ${jsonencode(local.id_token)} } }"
}

resource "local_sensitive_file" "kubeconfig-yaml" {
  filename = "kubeconfig.yaml"
  content  = yamlencode(jsondecode(data.jq_query.kubeconfig.result) )
}

#"oidc.tf"

resource "btp_subaccount_entitlement" "identity" {
  subaccount_id = btp_subaccount.subaccount.id
  service_name  = "identity"
  plan_name     = "application"
}

# custom idp
resource "btp_subaccount_trust_configuration" "custom_idp" {
  subaccount_id     = btp_subaccount.subaccount.id
  identity_provider = "${var.BTP_CUSTOM_IAS_TENANT}.${var.BTP_CUSTOM_IAS_DOMAIN}"
  name              = "${var.BTP_SUBACCOUNT}-${var.BTP_CUSTOM_IAS_TENANT}"
  depends_on        = [btp_subaccount_entitlement.identity]
}

data "btp_subaccount_service_plan" "identity_application" {
  depends_on    = [btp_subaccount_entitlement.identity]
  subaccount_id = btp_subaccount.subaccount.id
  offering_name = "identity"
  name          = "application"
}

resource "btp_subaccount_service_instance" "identity_application" {
  depends_on     = [btp_subaccount_trust_configuration.custom_idp]
  subaccount_id  = btp_subaccount.subaccount.id
  name           = "${var.BTP_SUBACCOUNT}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app"
  serviceplan_id = data.btp_subaccount_service_plan.identity_application.id
  parameters = jsonencode({
    user-access = "public"
    oauth2-configuration = {
      grant-types = [
        "authorization_code",
        "authorization_code_pkce_s256",
        "password",
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
    name         = "${var.BTP_SUBACCOUNT}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app",
    display-name = "${var.BTP_SUBACCOUNT}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app"
  })
}

resource "btp_subaccount_service_binding" "identity_application_binding" {
  subaccount_id       = btp_subaccount.subaccount.id
  name                = "${var.BTP_SUBACCOUNT}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app-binding"
  service_instance_id = btp_subaccount_service_instance.identity_application.id
  parameters = jsonencode({
    credential-type = "X509_GENERATED"
    key-length      = 4096
    validity        = 1
    validity-type   = "DAYS"
    app-identifier  = "kymaruntime"
  })
}

locals {
  idp = jsondecode(btp_subaccount_service_binding.identity_application_binding.credentials)
}

data "http" "token" {
  url = "${local.idp.url}/oauth2/token"
  method = "POST"
  request_headers = {
    Content-Type  = "application/x-www-form-urlencoded"
  }
  request_body = "grant_type=password&username=${var.BTP_BOT_USER}&password=${var.BTP_BOT_PASSWORD}&client_id=${local.idp.clientid}&scope=groups,email"
}

#"provider-sm.tf"

data "btp_subaccount_service_binding" "provider_sm" {
  count = var.BTP_PROVIDER_SUBACCOUNT_ID == null ? 0 : 1
  # count = try(var.BTP_PROVIDER_SUBACCOUNT_ID, false) ? 1 : 0
  subaccount_id = var.BTP_PROVIDER_SUBACCOUNT_ID
  name          = "provider-sm-binding"
}

#"subaccount.tf"

resource "btp_subaccount" "subaccount" {
  name      = var.BTP_SUBACCOUNT
  region    = var.BTP_SA_REGION
  subdomain = var.BTP_SUBACCOUNT
}

