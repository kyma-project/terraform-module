data "btp_subaccount" "reuse_subaccount" {
  count = var.BTP_USE_SUBACCOUNT_ID != null ? 1 : 0
  id    = var.BTP_USE_SUBACCOUNT_ID
}

locals {
  subaccount_name = var.BTP_USE_SUBACCOUNT_ID != null ? one(data.btp_subaccount.reuse_subaccount).name : one(btp_subaccount.subaccount).name
  subaccount_id   = var.BTP_USE_SUBACCOUNT_ID != null ? one(data.btp_subaccount.reuse_subaccount).id : one(btp_subaccount.subaccount).id
}

###
# Setup the subaccount including entitlements for Kyma
###
resource "btp_subaccount" "subaccount" {
  count     = var.BTP_USE_SUBACCOUNT_ID == null ? 1 : 0
  name      = var.BTP_NEW_SUBACCOUNT_NAME
  region    = var.BTP_NEW_SUBACCOUNT_REGION
  subdomain = var.BTP_NEW_SUBACCOUNT_NAME
}

resource "btp_subaccount_entitlement" "kyma" {
  subaccount_id = local.subaccount_id
  service_name  = "kymaruntime"
  plan_name     = var.BTP_KYMA_PLAN
  amount        = 1
}

resource "btp_subaccount_entitlement" "sm_operator_access" {
  subaccount_id = local.subaccount_id
  service_name  = "service-manager"
  plan_name     = "service-operator-access"
}

###
# Setup CIS
###
resource "btp_subaccount_entitlement" "cis" {
  subaccount_id = local.subaccount_id
  service_name  = "cis"
  plan_name     = "local"
}

data "btp_subaccount_service_plan" "cis" {
  depends_on = [btp_subaccount_entitlement.cis]

  subaccount_id = local.subaccount_id
  offering_name = "cis"
  name          = "local"
}

resource "btp_subaccount_service_instance" "cis_local" {
  depends_on = [btp_subaccount_entitlement.cis]

  subaccount_id  = local.subaccount_id
  name           = "cis-local"
  serviceplan_id = data.btp_subaccount_service_plan.cis.id
  parameters = jsonencode({
    "grantType" : "clientCredentials"
  })
}

resource "btp_subaccount_service_binding" "cis_local_binding" {
  depends_on = [btp_subaccount_service_instance.cis_local]

  subaccount_id       = local.subaccount_id
  name                = "cis-local-binding"
  service_instance_id = btp_subaccount_service_instance.cis_local.id
}

locals {
  cisCredentials = jsondecode(btp_subaccount_service_binding.cis_local_binding.credentials)
  cisBasicAuth   = base64encode("${local.cisCredentials.uaa.clientid}:${local.cisCredentials.uaa.clientsecret}")
}

###
# Setup the Kyma environment
###
resource "btp_subaccount_environment_instance" "kyma" {
  depends_on = [resource.btp_subaccount_entitlement.sm_operator_access]

  subaccount_id    = local.subaccount_id
  name             = "${local.subaccount_name}-kyma"
  environment_type = "kyma"
  service_name     = btp_subaccount_entitlement.kyma.service_name
  plan_name        = btp_subaccount_entitlement.kyma.plan_name
  parameters = jsonencode({
    modules        = { list = var.BTP_KYMA_MODULES }
    oidc           = var.BTP_KYMA_CUSTOM_OIDC
    name           = "${local.subaccount_name}-kyma"
    region         = var.BTP_KYMA_REGION
    administrators = var.BTP_KYMA_CUSTOM_ADMINISTRATORS
    autoScalerMin  = var.BTP_KYMA_AUTOSCALER_MIN
    autoScalerMax  = var.BTP_KYMA_AUTOSCALER_MAX
  })
  timeouts = {
    create = var.BTP_KYMA_SETUP_TIMEOUTS.create
    update = var.BTP_KYMA_SETUP_TIMEOUTS.update
    delete = var.BTP_KYMA_SETUP_TIMEOUTS.delete
  }
}

###
# Create Kyma environment binding via CIS provisioning API
###
# Fetch token from CIS API using client-credential service binding
data "http" "cis_api_token" {
  depends_on = [btp_subaccount_service_binding.cis_local_binding]

  url    = "${local.cisCredentials.uaa.url}/oauth/token?grant_type=client_credentials"
  method = "POST"
  request_headers = {
    Authorization = "Basic ${local.cisBasicAuth}"
  }
}

resource "terracurl_request" "cis_kyma_env_binding" {
  depends_on = [data.http.cis_api_token, btp_subaccount_environment_instance.kyma]

  name         = "cis_kyma_env_binding"
  url          = "${local.cisCredentials.endpoints.provisioning_service_url}/provisioning/v1/environments/${btp_subaccount_environment_instance.kyma.id}/bindings"
  method       = "PUT"
  request_body = jsonencode({ "parameters" = { "expiration_seconds" = 7200 } })

  headers = {
    Authorization = "Bearer ${jsondecode(data.http.cis_api_token.response_body).access_token}"
    Accept        = "application/json"
    content-type  = "application/json"
  }

  response_codes = [202]

  # Skip a HTTP call when destroying the resource, since the binding will be deleted when the Kyma cluster is deprovisioned
  destroy_skip = true

  lifecycle {
    ignore_changes = [
      # Ignore changes from the bearer token. They should not trigger a new binding.
      headers, destroy_headers
    ]
  }
}

###
# Store the kubeconfig and CA certificate as ressource
###
resource "terraform_data" "kubeconfig" {
  input = jsondecode(terracurl_request.cis_kyma_env_binding.response).credentials.kubeconfig
}

resource "terraform_data" "ca_cert" {
  input = base64decode(yamldecode(jsondecode(terracurl_request.cis_kyma_env_binding.response).credentials.kubeconfig).clusters.0.cluster.certificate-authority-data)
}

###
# Store the kubeconfig and CA certificate in local files after CIS binding is available
###
resource "local_sensitive_file" "kubeconfig_yaml" {
  count    = var.store_kubeconfig_locally ? 1 : 0
  filename = "kubeconfig.yaml"
  content  = jsondecode(terracurl_request.cis_kyma_env_binding.response).credentials.kubeconfig
}

resource "local_sensitive_file" "ca_cert" {
  count    = var.store_cacert_locally ? 1 : 0
  filename = "CA.crt"
  content  = base64decode(yamldecode(jsondecode(terracurl_request.cis_kyma_env_binding.response).credentials.kubeconfig).clusters.0.cluster.certificate-authority-data)
}
