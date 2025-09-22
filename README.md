<!-- Update this title with a descriptive name. Use sentence case. -->
# Terraform modules template project

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-cos-storage-defender?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-cos-storage-defender/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

TODO: Replace this with a description of the modules in this repo.


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-cos-storage-defender](#terraform-ibm-cos-storage-defender)
* [Submodules](./modules)
* [Examples](./examples)
    * [Advanced example](./examples/advanced)
    * [Advanced example](./examples/basic)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-cos-storage-defender

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

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

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the 'Sample IBM Cloud' service and roles with applicable values.
The required information can usually be found in the services official
IBM Cloud documentation.
To view all available service permissions, you can go in the
console at Manage > Access (IAM) > Access groups and click into an existing group
(or create a new one) and in the 'Access' tab click 'Assign access'.
-->

<!--
You need the following permissions to run this module:

- Service
    - **Resource group only**
        - `Viewer` access on the specific resource group
    - **Sample IBM Cloud** service
        - `Editor` platform access
        - `Manager` service access
-->

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.71.2, < 2.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | ./modules/cbr-rule-module | n/a |
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | ./modules/cbr-zone-module | n/a |
| <a name="module_cloud_logs"></a> [cloud\_logs](#module\_cloud\_logs) | ./modules/cloud_logs | n/a |
| <a name="module_cloud_logs_buckets"></a> [cloud\_logs\_buckets](#module\_cloud\_logs\_buckets) | ./modules/buckets | n/a |
| <a name="module_cos"></a> [cos](#module\_cos) | ./modules/cos | n/a |
| <a name="module_cos_bucket"></a> [cos\_bucket](#module\_cos\_bucket) | ./modules/buckets | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | ./modules/kms | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.cos_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.cos_to_kms](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [random_id.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/id) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |
| [ibm_is_vpc.single_vpc](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_vpc) | data source |
| [ibm_resource_group.existing_resource_group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ip_addresses"></a> [allowed\_ip\_addresses](#input\_allowed\_ip\_addresses) | Comma-separated list of allowed IP addresses | `string` | `""` | no |
| <a name="input_allowed_network_zone_name"></a> [allowed\_network\_zone\_name](#input\_allowed\_network\_zone\_name) | Optional custom name for CBR network zone | `string` | `"cyber-zone"` | no |
| <a name="input_allowed_vpc"></a> [allowed\_vpc](#input\_allowed\_vpc) | Single VPC JSON string with { name, region }, or empty string if not used | `string` | `""` | no |
| <a name="input_allowed_vpc_crns"></a> [allowed\_vpc\_crns](#input\_allowed\_vpc\_crns) | Comma-separated list of allowed VPC CRNs | `string` | `""` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name for the new Object Storage bucket. | `string` | `"cybervault-bucket"` | no |
| <a name="input_bucket_storage_class"></a> [bucket\_storage\_class](#input\_bucket\_storage\_class) | The storage class of the new bucket. Required only if `create_cos_bucket` is true. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`. | `string` | `"standard"` | no |
| <a name="input_cloud_log_instance_name"></a> [cloud\_log\_instance\_name](#input\_cloud\_log\_instance\_name) | The name for the Cloud Logs Instance. | `string` | `"Cloud-Logs"` | no |
| <a name="input_cloud_logs_bucket_endpoint"></a> [cloud\_logs\_bucket\_endpoint](#input\_cloud\_logs\_bucket\_endpoint) | The type of endpoint for the IBM terraform provider to manage the bucket. Possible values: `public`, `private`, `direct`. | `string` | `"public"` | no |
| <a name="input_cloud_logs_endpoint"></a> [cloud\_logs\_endpoint](#input\_cloud\_logs\_endpoint) | Service endpoint type for the Cloud Logs instance. Possible values: 'public', 'private', 'direct'. | `string` | `"public-and-private"` | no |
| <a name="input_cos_allowed_endpoint_types"></a> [cos\_allowed\_endpoint\_types](#input\_cos\_allowed\_endpoint\_types) | Allowed endpoint types for COS (public, private, all, or empty) | `string` | `"all"` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name for the IBM Cloud Object Storage instance provisioned by this module. Applies only if `create_cos_instance` is true. | `string` | `"cos-cybervault"` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group to provision the resources. | `string` | `"Default"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key to deploy resources. | `string` | n/a | yes |
| <a name="input_key_protect_name"></a> [key\_protect\_name](#input\_key\_protect\_name) | The name of the Key Protect instance to create. | `string` | `"key-protect"` | no |
| <a name="input_kp_plan"></a> [kp\_plan](#input\_kp\_plan) | Plan for the Key Protect instance. Valid plans are 'tiered-pricing' and 'cross-region-resiliency', for more information on these plans see [Key Protect pricing plan](https://cloud.ibm.com/docs/key-protect?topic=key-protect-pricing-plan). | `string` | `"tiered-pricing"` | no |
| <a name="input_logs_bucket_name"></a> [logs\_bucket\_name](#input\_logs\_bucket\_name) | The name for the new Object Storage bucket. | `string` | `"icl-logs-bucket"` | no |
| <a name="input_metrics_bucket_name"></a> [metrics\_bucket\_name](#input\_metrics\_bucket\_name) | The name for the new Object Storage bucket. | `string` | `"icl-metrics-bucket"` | no |
| <a name="input_object_locking_enabled"></a> [object\_locking\_enabled](#input\_object\_locking\_enabled) | Whether to create an object lock configuration. Applies only if `object_versioning_enabled` and `create_cos_bucket` are true. | `bool` | `false` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-us-south. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md). | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the bucket. If specified, set `cross_region_location` and `single_site_location` to `null`. | `string` | `"us-east"` | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | Retention period (in days) for logs and metrics stored in Cloud Logs. | `number` | `7` | no |
| <a name="input_role"></a> [role](#input\_role) | HMAC key role | `string` | `"Writer"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the COS bucket. |
| <a name="output_cos_bucket_endpoint"></a> [cos\_bucket\_endpoint](#output\_cos\_bucket\_endpoint) | The direct endpoint of the COS bucket. |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | The ID of the COS instance. |
| <a name="output_credentials_json"></a> [credentials\_json](#output\_credentials\_json) | The HMAC credentials JSON for the COS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
