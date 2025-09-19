# Cloud Logs
resource "ibm_resource_instance" "cloud_logs" {
  #   depends_on        = [time_sleep.wait_for_cos_authorization_policy]
  name              = var.icl_instance_name
  resource_group_id = var.resource_group_id
  service           = "logs"
  plan              = var.plan
  location          = var.region
  parameters = {
    "logs_bucket_crn"         = var.data_storage.logs_data.enabled ? var.data_storage.logs_data.bucket_crn : null
    "logs_bucket_endpoint"    = var.data_storage.logs_data.enabled ? var.data_storage.logs_data.bucket_endpoint : null
    "metrics_bucket_crn"      = var.data_storage.metrics_data.enabled ? var.data_storage.metrics_data.bucket_crn : null
    "metrics_bucket_endpoint" = var.data_storage.metrics_data.enabled ? var.data_storage.metrics_data.bucket_endpoint : null
    "retention_period"        = var.retention_period
  }
  service_endpoints = var.service_endpoints
}
