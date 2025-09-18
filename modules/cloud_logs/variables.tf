variable "icl_instance_name" {
  description = "Name of the IBM Cloud Logs instance."
  type        = string
  default     = "icl-cybervault"
}

variable "resource_group_id" {
  description = "The resource group ID where the Cloud Logs instance will be provisioned."
  type        = string
}

variable "plan" {
  type        = string
  description = "The IBM Cloud Logs plan to provision. Available: standard"
  default     = "standard"

  validation {
    condition = anytrue([
      var.plan == "standard",
    ])
    error_message = "The plan value must be one of the following: standard."
  }
}

variable "resource_tags" {
  description = "A list of tags to assign to the Cloud Logs instance."
  type        = list(string)
  default     = []
}

variable "region" {
  description = "Region where the Cloud Logs instance will be created."
  type        = string
  default     = "us-south"
}

variable "retention_period" {
  description = "Retention period (in days) for logs and metrics stored in Cloud Logs."
  type        = number
  default     = 7
}

variable "service_endpoints" {
  description = "Service endpoint type for the Cloud Logs instance. Possible values: 'public', 'private', 'direct'."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection! Must be one of: public, private, direct."
  }
}

variable "data_storage" {
  description = <<EOT
Configuration for storage of logs and metrics data.
- logs_data.enabled (bool): Enable storing logs in a COS bucket.
- logs_data.bucket_crn (string): CRN of the COS bucket for logs.
- logs_data.bucket_endpoint (string): Endpoint of the COS bucket for logs.
- metrics_data.enabled (bool): Enable storing metrics in a COS bucket.
- metrics_data.bucket_crn (string): CRN of the COS bucket for metrics.
- metrics_data.bucket_endpoint (string): Endpoint of the COS bucket for metrics.
EOT
  type = object({
    logs_data = object({
      enabled         = bool
      bucket_crn      = string
      bucket_endpoint = string
    })
    metrics_data = object({
      enabled         = bool
      bucket_crn      = string
      bucket_endpoint = string
    })
  })
}
