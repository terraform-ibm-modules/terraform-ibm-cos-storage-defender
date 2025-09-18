variable "region" {
  type        = string
  description = "The IBM Cloud region where the COS bucket will be provisioned (e.g., us-south, eu-de, jp-tok)."
}

variable "cross_region_location" {
  type        = string
  description = "Cross-region location for the COS bucket (e.g., us, eu, ap). Used when creating cross-region buckets."
  default     = null
}

variable "single_site_location" {
  type        = string
  description = "Single-site location for the COS bucket (e.g., dal10, lon06, tok04). Used when creating single-site buckets."
  default     = null
}

variable "cos_instance_id" {
  type        = string
  description = "The ID of the existing Cloud Object Storage (COS) instance where the bucket will be created."
}

variable "bucket_name" {
  type        = string
  description = "The name of the COS bucket to create."
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to manage the bucket. Possible values: `public`, `private`, `direct`."
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The specified management_endpoint_type_for_bucket is not a valid selection!"
  }
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the COS bucket. Possible values: `standard`, `vault`, `cold`, `onerate_active`, etc."
}

variable "hard_quota" {
  type        = number
  description = "The hard quota (in GB) for the bucket. Set to 0 for unlimited."
  default     = 1024
}

variable "force_delete" {
  type        = bool
  description = "Whether to force delete the bucket even if it contains objects."
  default     = true
}

variable "object_locking_enabled" {
  type        = bool
  description = "Enable object locking for the bucket (WORM)."
  default     = false
}

variable "create_cos_bucket" {
  type        = bool
  description = "Flag to control whether a COS bucket should be created."
  default     = true
}

variable "kms_encryption_enabled" {
  type        = bool
  description = "Enable KMS encryption for the COS bucket using a Key Protect or HPCS key."
  default     = false
}

variable "kms_key_crn" {
  type        = string
  description = "The CRN of the KMS key to use for encryption when kms_encryption_enabled is true."
  default     = null
}