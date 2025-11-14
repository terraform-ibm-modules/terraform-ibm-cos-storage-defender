# Terraform modules template project

[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-cos-storage-defender?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-cos-storage-defender/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

This Terraform configuration provisions a secure IBM Cloud Object Storage environment with integrated Key Protect encryption, Cloud Logs, and Context-Based Restrictions.
It automates creation of COS buckets (CyberVault, Logs, Metrics) and manages encryption keys and IAM policies.
Designed to ensure data protection, compliance, and controlled network access within IBM Cloud.

<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-cos-storage-defender](#terraform-ibm-cos-storage-defender)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-cos-storage-defender

### Usage


```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "X.Y.Z"  # Lock into a provider version that satisfies the module constraints
    }
  }
}

locals {
    region = "us-south"
}

provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"  # replace with apikey value
  region           = local.region
}

module "module_template" {
  source            = "terraform-ibm-modules/<replace>/ibm"
  version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  region            = local.region
  name              = "instance-name"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" # Replace with the actual ID of resource group to use
}
```

### Required access policies


The following IBM Cloud IAM permissions are required for the user or service ID running this Terraform configuration:

- Resource Group
  - `Viewer` or `Editor` on the target Resource Group

- Cloud Object Storage (COS)
  - `Manager` on the COS service instance
  - `Manager` on COS buckets

- Key Protect (KMS)
  - `Manager` on the Key Protect instance
  - `Writer` to create and manage encryption keys

- IAM Authorization Policies
  - `Editor` or higher on IAM Access Management to create COS → KMS and Cloud Logs → COS authorization policies

- Cloud Logs
  - `Manager` on the Cloud Logs service instance

- Context-Based Restrictions (CBR)
  - `Administrator` on Context-Based Restrictions to create zones and rules

- VPC / Networking (optional, if using network restrictions)
  - `Viewer` on VPC resources to read VPC details

Ensure that the API key or IAM identity used has sufficient access to all these services within the same IBM Cloud account and region.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.71.2, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.33.7 |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module | 1.33.7 |
| <a name="module_cloud_logs"></a> [cloud\_logs](#module\_cloud\_logs) | terraform-ibm-modules/cloud-logs/ibm | 1.9.6 |
| <a name="module_cos"></a> [cos](#module\_cos) | terraform-ibm-modules/cos/ibm | 10.5.2 |
| <a name="module_cos_buckets"></a> [cos\_buckets](#module\_cos\_buckets) | terraform-ibm-modules/cos/ibm//modules/buckets | 10.5.2 |
| <a name="module_key"></a> [key](#module\_key) | terraform-ibm-modules/kms-key/ibm | 1.4.2 |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-ibm-modules/key-protect/ibm | 2.10.17 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.4.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.cos_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.cos_to_kms](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ip_addresses"></a> [allowed\_ip\_addresses](#input\_allowed\_ip\_addresses) | List of allowed IPv4 addresses. This will restrict access to the bucket from only specifically allowed IP addresses. Entering values in this field will result in the creation of a new network zone. | `list(string)` | `null` | no |
| <a name="input_allowed_network"></a> [allowed\_network](#input\_allowed\_network) | Allowed networks for the Key Protect instance. Possible values: 'private-only', 'public-and-private'. | `string` | `"private-only"` | no |
| <a name="input_allowed_network_zone_name"></a> [allowed\_network\_zone\_name](#input\_allowed\_network\_zone\_name) | Name used for new network zone created if values are entered in the allowed\_ip\_addresses, allowed\_vpc, or allowed\_vpc\_crns fields | `string` | `"cyber-zone"` | no |
| <a name="input_allowed_vpc"></a> [allowed\_vpc](#input\_allowed\_vpc) | List of allowed VPCs. This will restrict access to the bucket from only specifically allowed VPCs. Entering values in this field will result in the creation of a new network zone. Learn more: https://cloud.ibm.com/objectstorage/create#pricing | `string` | `null` | no |
| <a name="input_allowed_vpc_crns"></a> [allowed\_vpc\_crns](#input\_allowed\_vpc\_crns) | List of allowed VPC CRNs. Restricts access to the bucket. Set to null for no restriction. | `list(string)` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name for the IBM Cloud Object Storage bucket provisioned by this solution. A default name has been provided. The instance will be named with the prefix plus this value in the format <prefix>-value. The bucket name will also be appended with a randomly generated string of unique characters. | `string` | `"cybervault-bucket"` | no |
| <a name="input_bucket_storage_class"></a> [bucket\_storage\_class](#input\_bucket\_storage\_class) | The storage class of the new Cloud Object Storage bucket. Learn More: https://cloud.ibm.com/objectstorage/create#pricing | `string` | `"smart"` | no |
| <a name="input_cloud_log_instance_name"></a> [cloud\_log\_instance\_name](#input\_cloud\_log\_instance\_name) | The name for the Cloud Logs instance provisioned by this solution. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value. | `string` | `"Cloud-Logs"` | no |
| <a name="input_cloud_logs_bucket_class"></a> [cloud\_logs\_bucket\_class](#input\_cloud\_logs\_bucket\_class) | The storage class of the new bucket for cloud logs bucket. Required only if `create_cos_bucket` is true. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`. | `string` | `"standard"` | no |
| <a name="input_cloud_logs_plan"></a> [cloud\_logs\_plan](#input\_cloud\_logs\_plan) | The IBM Cloud Logs plan to provision. Available: standard | `string` | `"standard"` | no |
| <a name="input_cos_allowed_endpoint_types"></a> [cos\_allowed\_endpoint\_types](#input\_cos\_allowed\_endpoint\_types) | Restrict access to the COS bucket through specific endpoint types. By specifying a value here, access to the bucket will be restricted to that endpoint type. Public endpoints are used for traffic originating from outside IBM Cloud. Private endpoints are used for traffic coming from other parts ofIBM Cloud, excluding VPCs. Direct endpoints are used for traffic coming from customer VPCs. | `string` | `"all"` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name for the IBM Cloud Object Storage instance provisioned by this module. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value. | `string` | `"cos-cybervault"` | no |
| <a name="input_cos_location"></a> [cos\_location](#input\_cos\_location) | The location for the Object Storage instance. | `string` | `"global"` | no |
| <a name="input_enforcement_mode"></a> [enforcement\_mode](#input\_enforcement\_mode) | (String) The rule enforcement mode | `string` | `"disabled"` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group to provision the resources. If not provided the default resource group will be used. | `string` | `null` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to force delete the key when deleting the resource. | `bool` | `true` | no |
| <a name="input_hard_quota"></a> [hard\_quota](#input\_hard\_quota) | The hard quota (in GB) for the bucket. Set to 0 for unlimited. May be null. | `number` | `1024` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key to deploy resources. | `string` | n/a | yes |
| <a name="input_key_protect_name"></a> [key\_protect\_name](#input\_key\_protect\_name) | The name for the Key Protect instance provisioned by this solution. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value. | `string` | `"key-protect"` | no |
| <a name="input_key_protect_plan"></a> [key\_protect\_plan](#input\_key\_protect\_plan) | Plan for the Key Protect instance. Valid plans are 'tiered-pricing' and 'cross-region-resiliency', for more information on these plans see [Key Protect pricing plan](https://cloud.ibm.com/docs/key-protect?topic=key-protect-pricing-plan). | `string` | `"tiered-pricing"` | no |
| <a name="input_kms_endpoint_type"></a> [kms\_endpoint\_type](#input\_kms\_endpoint\_type) | Endpoint to use when creating the Key | `string` | `"private"` | no |
| <a name="input_logs_bucket_name"></a> [logs\_bucket\_name](#input\_logs\_bucket\_name) | The name for the new Object Storage logs bucket. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value. A unique suffix may also be appended. | `string` | `"logs-bucket"` | no |
| <a name="input_metrics_bucket_name"></a> [metrics\_bucket\_name](#input\_metrics\_bucket\_name) | The name for the new Object Storage metrics bucket. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value. A unique suffix may also be appended. | `string` | `"metrics-bucket"` | no |
| <a name="input_object_lock_duration_years"></a> [object\_lock\_duration\_years](#input\_object\_lock\_duration\_years) | The number of years for the object lock duration. If you specify a number of years, do not specify a value for `object_lock_duration_days`. | `number` | `1` | no |
| <a name="input_object_locking_enabled"></a> [object\_locking\_enabled](#input\_object\_locking\_enabled) | Enable object lock to keep data immutable for the retention period. This will also enable object versioning on the bucket. Learn More: https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-immutable | `bool` | `false` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To skip using a prefix, set this value to `null` or an empty string. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where all resources (COS instance and buckets, Key Protect, Cloud Logs, etc.) will be provisioned. | `string` | `"us-east"` | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | Retention period (in days) for logs and metrics stored in Cloud Logs. | `number` | `7` | no |
| <a name="input_role"></a> [role](#input\_role) | This is the role that will be granted to the service credential used by Defender when making requests to COS. The Writer role has been selected by default since it contains the minimum set of permissions needed by Defender. | `string` | `"Writer"` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The type of the service endpoint that will be set for the IBM Cloud Logs instance. Allowed values: public-and-private. | `string` | `"public-and-private"` | no |
| <a name="input_standard_key"></a> [standard\_key](#input\_standard\_key) | Specifies whether to create a standard encryption key (true) or import an existing key (false).For more information, see: [Key Protect concepts](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-understand-concepts). | `bool` | `false` | no |
| <a name="input_zone_description"></a> [zone\_description](#input\_zone\_description) | Description of the zone | `string` | `"CBR zone created by Terraform"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | The ID of the COS instance. |
| <a name="output_credentials_json"></a> [credentials\_json](#output\_credentials\_json) | The HMAC credentials JSON for the COS instance. |
| <a name="output_cybervault_bucket_endpoint"></a> [cybervault\_bucket\_endpoint](#output\_cybervault\_bucket\_endpoint) | The direct S3 endpoint of the Cybervault COS bucket. |
| <a name="output_cybervault_bucket_name"></a> [cybervault\_bucket\_name](#output\_cybervault\_bucket\_name) | The name of the Cybervault COS bucket. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
