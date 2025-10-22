##############################################################################
# Common variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud platform API key to deploy resources."
  sensitive   = true
}

variable "region" {
  description = "The IBM Cloud region where all resources (COS instance and buckets, Key Protect, Cloud Logs, etc.) will be provisioned. If specifying cross-region or single-site locations for COS buckets, set `cross_region_location` and `single_site_location` to `null`."
  type        = string
  default     = "us-east"
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To skip using a prefix, set this value to `null` or an empty string. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources. If not provided the default resource group will be used."
  default     = null
}


##############################################################################
# COS instance variables
##############################################################################

variable "cos_instance_name" {
  type        = string
  description = "The name for the IBM Cloud Object Storage instance provisioned by this module. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value. Applies only if `create_cos_instance` is true."
  default     = "cos-cybervault"
}

variable "role" {
  description = "This is the role that will be granted to the service credential used by Defender when making requests to COS. The Writer role has been selected by default since it contains the minimum set of permissions needed by Defender."
  type        = string
  default     = "Writer"
}

variable "cos_location" {
  description = "The location for the Object Storage instance."
  type        = string
  default     = "global"
}

##############################################################################
# KMS instance variables
##############################################################################

variable "key_protect_name" {
  type        = string
  description = "The name for the Key Protect instance provisioned by this solution. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value."
  default     = "key-protect"
}

variable "key_protect_plan" {
  type        = string
  description = "Plan for the Key Protect instance. Valid plans are 'tiered-pricing' and 'cross-region-resiliency', for more information on these plans see [Key Protect pricing plan](https://cloud.ibm.com/docs/key-protect?topic=key-protect-pricing-plan)."
  default     = "tiered-pricing"

  validation {
    condition     = contains(["tiered-pricing", "cross-region-resiliency"], var.key_protect_plan)
    error_message = "`plan` must be one of: 'tiered-pricing', 'cross-region-resiliency'."
  }

  validation {
    condition     = var.key_protect_plan == "tiered-pricing" ? true : (var.key_protect_plan == "cross-region-resiliency" && contains(["us-south", "eu-de", "jp-tok"], var.region))
    error_message = "'cross-region-resiliency' is only available for the following regions: 'us-south', 'eu-de', 'jp-tok'."
  }
}

variable "allowed_network" {
  type        = string
  description = "Allowed networks for the Key Protect instance. Possible values: 'private-only', 'public-and-private'."
  default     = "private-only"

  validation {
    condition     = can(regex("public-and-private|private-only", var.allowed_network))
    error_message = "Valid values for allowed_network are 'public-and-private' or 'private-only'."
  }
}

variable "standard_key" {
  type        = bool
  description = "Specifies whether to create a standard encryption key (true) or import an existing key (false).For more information, see: [Key Protect concepts](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-understand-concepts)."
  default     = false
}

variable "kms_endpoint_type" {
  type        = string
  description = "Endpoint to use when creating the Key"
  default     = "private"

  validation {
    condition     = can(regex("^(public|private)$", var.kms_endpoint_type))
    error_message = "Variable 'kms_endpoint_type' must be 'public' or 'private'."
  }
}

##############################################################################
# COS bucket variables
##############################################################################

variable "bucket_name" {
  type        = string
  description = "The name for the IBM Cloud Object Storage bucket provisioned by this solution. A default name has been provided. The instance will be named with the prefix plus this value in the format <prefix>-value. The bucket namewill also be appended with a randomly generated string of unique characters."
  default     = "cybervault-bucket"
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the new bucket. Required only if `create_cos_bucket` is true. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`."
  default     = "smart"

  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$|^onerate_active", var.bucket_storage_class))
    error_message = "Variable 'bucket_storage_class' must be 'standard', 'vault', 'cold', 'smart' or 'onerate_active'."
  }
}

variable "object_locking_enabled" {
  description = "Whether to create an object lock configuration. Applies only if `object_versioning_enabled` and `create_cos_bucket` are true."
  type        = bool
  default     = false
}

variable "object_lock_duration_years" {
  description = "The number of years for the object lock duration. If you specify a number of years, do not specify a value for `object_lock_duration_days`. Applies only if `create_cos_bucket` is set to `true`."
  type        = number
  default     = 1
}

variable "hard_quota" {
  type        = number
  description = "The hard quota (in GB) for the bucket. Set to 0 for unlimited."
  default     = 1024
}

variable "force_delete" {
  type        = bool
  description = "Whether to force delete the key when deleting the resource."
  default     = true
}

##############################################################################
# cloud logs variable
##############################################################################


variable "cloud_log_instance_name" {
  type        = string
  description = "The name for the Cloud Logs instance provisioned by this solution. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value."
  default     = "Cloud-Logs"
}

variable "service_endpoints" {
  description = "The type of the service endpoint that will be set for the IBM Cloud Logs instance. Allowed values: public-and-private."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection. Allowed values: public-and-private."
  }
}

variable "logs_bucket_name" {
  type        = string
  description = "The name for the new Object Storage logs bucket. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value. A unique suffix may also be appended."
  default     = "logs-bucket"
}

variable "metrics_bucket_name" {
  type        = string
  description = "The name for the new Object Storage metrics bucket. If a prefix is provided via the 'prefix' variable, it will be prepended to this value in the format <prefix>-value. A unique suffix may also be appended."
  default     = "metrics-bucket"
}

variable "cloud_logs_bucket_class" {
  type        = string
  description = "The storage class of the new bucket for cloud logs bucket. Required only if `create_cos_bucket` is true. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`."
  default     = "standard"

  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$|^onerate_active", var.cloud_logs_bucket_class))
    error_message = "Variable 'cloud_logs_bucket_class' must be 'standard', 'vault', 'cold', 'smart' or 'onerate_active'."
  }
}

variable "retention_period" {
  description = "Retention period (in days) for logs and metrics stored in Cloud Logs."
  type        = number
  default     = 7
}

variable "cloud_logs_plan" {
  type        = string
  description = "The IBM Cloud Logs plan to provision. Available: standard"
  default     = "standard"

  validation {
    condition = anytrue([
      var.cloud_logs_plan == "standard",
    ])
    error_message = "The plan value must be one of the following: standard."
  }
}

##############################################################################
# CBR rule creation variables
##############################################################################

variable "allowed_vpc" {
  description = "List of allowed VPC. This will restrict access to the bucket from only specifically allowed VPC.  Entering values in this field will result in the creation of a new network zone."
  type        = string
  default     = null
  nullable    = true
}

variable "allowed_vpc_crns" {
  description = "Comma-separated list of allowed VPC CRNs. This will restrict access to the bucket from only specifically allowed VPC CRNs.  Entering values in this field will result in the creation of a new network zone."
  type        = list(string)
  default     = null
  nullable    = true
}

variable "allowed_ip_addresses" {
  description = "List of allowed IPv4 addresses. This will restrict access to the bucket from only specifically allowed IP addresses. Entering values in this field will result in the creation of a new network zone."
  type        = list(string)
  default     = null
  nullable    = true

  validation {
    condition = (
      var.allowed_ip_addresses == null ||
      alltrue([
        for ip in var.allowed_ip_addresses != null ? var.allowed_ip_addresses : [] :
        can(regex(
          "^((25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})$",
          trimspace(ip)
        ))
      ])
    )
    error_message = "allowed_ip_addresses must be a list of valid IPv4 addresses (e.g., 192.168.1.1)."
  }
}

variable "enforcement_mode" {
  type        = string
  description = "(String) The rule enforcement mode"
  default     = "enabled"
  validation {
    condition = anytrue([
      var.enforcement_mode == "enabled",
      var.enforcement_mode == "disabled",
      var.enforcement_mode == "report"
    ])
    error_message = "Valid values for enforcement mode can be 'enabled', 'disabled' and 'report'"
  }
}

variable "allowed_network_zone_name" {
  description = "Name used for new network zone created if values are entered in the allowed_ip_addresses, allowed_vpc, or allowed_vpc_crns fields"
  type        = string
  default     = "cyber-zone"
}

variable "cos_allowed_endpoint_types" {
  description = "Restrict access to the COS bucket through specific endpoint types. By specifying a value here, access to the bucket will be restricted to that endpoint type. Public endpoints are used for traffic originating from outside IBM Cloud. Private endpoints are used for traffic coming from other parts ofIBM Cloud, excluding VPCs. Direct endpoints are used for traffic coming from customer VPCs."
  type        = string
  default     = "all"

  validation {
    condition     = contains(["public", "private", "all"], var.cos_allowed_endpoint_types)
    error_message = "Invalid value for cos_allowed_endpoint_types. Allowed values are: 'public', 'private', 'all'."
  }
}

variable "zone_description" {
  description = "Description of the zone"
  type        = string
  default     = "CBR zone created by Terraform"
}
