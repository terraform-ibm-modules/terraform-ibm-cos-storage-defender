########################################################################################################################
# Outputs
########################################################################################################################

output "cos_instance_id" {
  value       = module.cos.cos_instance_id
  description = "The ID of the COS instance."
}

output "credentials_json" {
  value       = module.cos.resource_keys
  description = "The HMAC credentials JSON for the COS instance."
  sensitive   = true
}

output "cybervault_bucket_name" {
  description = "The name of the Cybervault COS bucket."
  value       = module.cos_buckets["cybervault"].buckets[local.cybervault_bucket].bucket_name
}

output "cybervault_bucket_endpoint" {
  description = "The direct S3 endpoint of the Cybervault COS bucket."
  value       = module.cos_buckets["cybervault"].buckets[local.cybervault_bucket].s3_endpoint_direct
}
