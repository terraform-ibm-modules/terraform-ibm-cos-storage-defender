# Looks up an existing resource group by name

data "ibm_resource_group" "existing_resource_group" {
  name = var.existing_resource_group_name
}

# Configure locals
locals {
  effective_cos_instance_name = (
    var.cos_instance_name != "" ? var.cos_instance_name : "cos-cybervault"
  )

  safe_prefix       = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""
  cos_instance_name = "${local.safe_prefix}${local.effective_cos_instance_name}"
  cos_plan          = var.bucket_storage_class == "onerate_active" ? "cos-one-rate-plan" : "standard"
  hmac_key_name     = "${local.safe_prefix}hmac-creds"
}

# Create Cos Instance

module "cos" {
  source              = "terraform-ibm-modules/cos/ibm"
  version             = "10.2.21"
  cos_instance_name   = local.cos_instance_name
  cos_plan            = local.cos_plan
  create_cos_instance = true
  create_cos_bucket   = false
  cos_location        = var.cos_location
  resource_group_id   = data.ibm_resource_group.existing_resource_group.id

  resource_keys = [
    {
      name                      = local.hmac_key_name
      key_name                  = null
      generate_hmac_credentials = true
      role                      = var.role
      service_id_crn            = null
    }
  ]
}

data "ibm_iam_account_settings" "iam_account_settings" {
}

locals {
  effective_key_protect_name = (
    var.key_protect_name != "" ? var.key_protect_name : "key-protect"
  )
  key_protect_name = "${local.safe_prefix}${local.effective_key_protect_name}"
  create_key       = true
  key_name         = "${local.safe_prefix}${var.bucket_name}-cos-key"
}

module "kms" {
  source            = "terraform-ibm-modules/key-protect/ibm"
  version           = "2.10.12"
  key_protect_name  = local.key_protect_name
  region            = var.region
  resource_group_id = data.ibm_resource_group.existing_resource_group.id
  plan              = var.kp_plan
  allowed_network   = var.allowed_network
}

module "key" {
  source          = "terraform-ibm-modules/kms-key/ibm"
  version         = "1.4.2"
  count           = local.create_key ? 1 : 0
  key_name        = local.key_name
  kms_instance_id = module.kms.key_protect_guid
  force_delete    = true
  endpoint_type   = var.endpoint_type
  standard_key    = var.standard_key
}


locals {
  create_authorization_policy = true
}

# COS → KMS authorization policy
resource "ibm_iam_authorization_policy" "cos_to_kms" {
  count = local.create_authorization_policy ? 1 : 0

  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = module.cos.cos_instance_guid
  target_service_name         = "kms"
  target_resource_instance_id = module.kms.key_protect_guid
  roles                       = ["Reader"]
}

locals {
  effective_bucket_name = (
    var.bucket_name != "" ? var.bucket_name : "cybervault-bucket"
  )
  bucket_name = "${local.safe_prefix}${local.effective_bucket_name}"

  # based on region set region location for resiliancy
  cross_region_location  = null
  single_site_location   = null
  kms_encryption_enabled = true
}

module "cos_bucket" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "10.2.21"
  bucket_configs = [
    {
      bucket_name                = local.bucket_name
      kms_encryption_enabled     = local.kms_encryption_enabled
      kms_key_crn                = local.kms_encryption_enabled ? module.key[0].crn : null
      region_location            = var.region
      cross_region_location      = local.cross_region_location
      single_site_location       = local.single_site_location
      resource_instance_id       = module.cos.cos_instance_id
      storage_class              = var.bucket_storage_class
      hard_quota                 = var.hard_quota
      force_delete               = var.force_delete
      object_locking_enabled     = var.object_locking_enabled
      object_lock_duration_years = var.object_lock_duration_years
      object_versioning = {
        enable = var.object_locking_enabled
      }
      skip_iam_authorization_policy = true
      add_bucket_name_suffix        = true
    }
  ]
  depends_on = [ibm_iam_authorization_policy.cos_to_kms]
}

locals {
  cos_bucket_name = module.cos_bucket.buckets[local.bucket_name].bucket_name
}

locals {
  logs_bucket_name    = "${local.safe_prefix}${var.logs_bucket_name}"
  metrics_bucket_name = "${local.safe_prefix}${var.metrics_bucket_name}"
}

module "icl_data_bucket" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "10.2.21"
  bucket_configs = [
    {
      bucket_name                   = local.logs_bucket_name
      kms_encryption_enabled        = local.kms_encryption_enabled
      kms_key_crn                   = local.kms_encryption_enabled ? module.key[0].crn : null
      region_location               = var.region
      cross_region_location         = local.cross_region_location
      single_site_location          = local.single_site_location
      resource_instance_id          = module.cos.cos_instance_id
      storage_class                 = var.cloud_logs_bucket_class
      hard_quota                    = var.hard_quota
      force_delete                  = var.force_delete
      skip_iam_authorization_policy = true
      add_bucket_name_suffix        = true

    }
  ]
  depends_on = [ibm_iam_authorization_policy.cos_to_kms]
}

module "icl_metrics_bucket" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "10.2.21"
  bucket_configs = [
    {
      bucket_name                   = local.metrics_bucket_name
      kms_encryption_enabled        = local.kms_encryption_enabled
      kms_key_crn                   = local.kms_encryption_enabled ? module.key[0].crn : null
      region_location               = var.region
      cross_region_location         = local.cross_region_location
      single_site_location          = local.single_site_location
      resource_instance_id          = module.cos.cos_instance_id
      storage_class                 = var.cloud_logs_bucket_class
      hard_quota                    = var.hard_quota
      force_delete                  = var.force_delete
      skip_iam_authorization_policy = true
      add_bucket_name_suffix        = true
    }
  ]
  depends_on = [ibm_iam_authorization_policy.cos_to_kms]
}

locals {
  effective_cloud_log_instance_name = (
    var.cloud_log_instance_name != "" ? var.cloud_log_instance_name : "Cloud-Logs"
  )
  cloud_log_instance_name = "${local.safe_prefix}${local.effective_cloud_log_instance_name}"

  data_storage = {
    logs_data = {
      enabled         = true
      bucket_crn      = module.icl_data_bucket.buckets[local.logs_bucket_name].bucket_crn
      bucket_endpoint = module.icl_data_bucket.buckets[local.logs_bucket_name].s3_endpoint_direct
    }
    metrics_data = {
      enabled         = true
      bucket_crn      = module.icl_metrics_bucket.buckets[local.metrics_bucket_name].bucket_crn
      bucket_endpoint = module.icl_metrics_bucket.buckets[local.metrics_bucket_name].s3_endpoint_direct
    }
  }
}


resource "ibm_iam_authorization_policy" "cos_policy" {
  count               = 1
  source_service_name = "logs"
  roles               = ["Writer"]
  description         = "Allow Cloud logs instances `Writer` access to the COS bucket with ID "

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "cloud-object-storage"
  }

  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = data.ibm_iam_account_settings.iam_account_settings.account_id
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = module.cos.cos_instance_guid
  }
}

module "cloud_logs" {
  source                        = "terraform-ibm-modules/cloud-logs/ibm"
  version                       = "1.6.29"
  depends_on                    = [ibm_iam_authorization_policy.cos_policy]
  instance_name                 = local.cloud_log_instance_name
  plan                          = var.icl_plan
  region                        = var.region
  resource_group_id             = data.ibm_resource_group.existing_resource_group.id
  service_endpoints             = var.cloud_logs_endpoint
  retention_period              = var.retention_period
  policies                      = []
  skip_logs_routing_auth_policy = true
  data_storage = {
    logs_data = {
      enabled              = local.data_storage.logs_data.enabled ? true : false
      bucket_crn           = local.data_storage.logs_data.enabled ? local.data_storage.logs_data.bucket_crn : null
      bucket_endpoint      = local.data_storage.logs_data.enabled ? local.data_storage.logs_data.bucket_endpoint : null
      skip_cos_auth_policy = true
    }
    metrics_data = {
      enabled              = local.data_storage.metrics_data.enabled ? true : false
      bucket_crn           = local.data_storage.metrics_data.enabled ? local.data_storage.metrics_data.bucket_crn : null
      bucket_endpoint      = local.data_storage.metrics_data.enabled ? local.data_storage.metrics_data.bucket_endpoint : null
      skip_cos_auth_policy = true
    }
  }
}

locals {
  account_id = data.ibm_iam_account_settings.iam_account_settings.account_id

  # Allowed endpoint types
  endpoint_context = (
    var.cos_allowed_endpoint_types == "all" ? [
      { name = "endpointType", value = "private" },
      { name = "endpointType", value = "public" }
    ] :
    var.cos_allowed_endpoint_types != "" ? [
      { name = "endpointType", value = var.cos_allowed_endpoint_types }
    ] : []
  )

  # Parse inputs for zone creation
  allowed_vpc_obj           = (var.allowed_vpc != "" && var.allowed_vpc != "-") ? jsondecode(var.allowed_vpc) : null
  allowed_vpc_crns_list     = var.allowed_vpc_crns != "" ? [for crn in split(",", var.allowed_vpc_crns) : trimspace(crn)] : []
  allowed_ip_addresses_list = var.allowed_ip_addresses != "" ? [for ip in split(",", var.allowed_ip_addresses) : trimspace(ip)] : []
}


# Fetch the VPC if provided
data "ibm_is_vpc" "single_vpc" {
  count = (
    local.allowed_vpc_obj != null &&
    try(local.allowed_vpc_obj.region, null) == var.region
  ) ? 1 : 0

  name = local.allowed_vpc_obj.name
}

locals {
  # If data.ibm_is_vpc.single_vpc uses `count`, then this works:
  allowed_vpc_list = length(data.ibm_is_vpc.single_vpc) > 0 ? [data.ibm_is_vpc.single_vpc[0].crn] : []

  # True if any of the allow-lists are non-empty
  use_custom_zone = length(local.allowed_vpc_list) > 0 || length(local.allowed_vpc_crns_list) > 0 || length(local.allowed_ip_addresses_list) > 0

  # Create rule if you have *any* allowed sources defined
  create_cbr_rule = length(local.allowed_vpc_list) > 0 || length(local.allowed_vpc_crns_list) > 0 || length(local.allowed_ip_addresses_list) > 0
}

module "cbr_zone" {
  count            = local.create_cbr_rule ? 1 : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.33.2"
  name             = "${local.safe_prefix}${var.allowed_network_zone_name}"
  account_id       = local.account_id # pragma: allowlist secret
  zone_description = var.zone_description
  addresses = concat(
    [for vpc in local.allowed_vpc_list : { type = "vpc", value = vpc }],
    [for crn in local.allowed_vpc_crns_list : { type = "vpc", value = crn }],
    [for ip in local.allowed_ip_addresses_list : { type = "ipAddress", value = ip }]
  )
  excluded_addresses = []
}

##############################################################################
# Final context attributes for the rule
##############################################################################
locals {
  context_attributes = concat(
    local.endpoint_context,
    local.use_custom_zone ? [
      { name = "networkZoneId", value = module.cbr_zone[0].zone_id }
    ] : []
  )

  cos_rule_resources = [
    {
      attributes = [
        { name = "accountId", value = local.account_id },
        { name = "serviceName", value = "cloud-object-storage" },
        { name = "serviceInstance", value = module.cos.cos_instance_guid, operator = "stringEquals" }
      ]
    }
  ]

  cos_rule_operations = [
    {
      api_types = [
        { api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:" }
      ]
    }
  ]
}

module "cbr_rule" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.33.2"
  count            = local.create_cbr_rule ? 1 : 0
  rule_description = "CBR rule for COS"
  enforcement_mode = "disabled"

  rule_contexts = [
    for ctx in local.context_attributes : {
      attributes = [ctx]
    }
  ]

  resources  = local.cos_rule_resources
  operations = local.cos_rule_operations

  depends_on = [
    module.cos,
    module.cos_bucket,
    module.icl_data_bucket,
    module.icl_metrics_bucket,
    module.cloud_logs,
    module.kms
  ]
}
