########################################################################################################################
# Outputs
########################################################################################################################

#
# Developer tips:
#   - Below are some good practise sample outputs
#   - They should be updated for outputs applicable to the module being added
#   - Use variable validation when possible
#

output "cos_instance_id" {
  value       = module.cos.cos_instance_id
  description = "The ID of the COS instance."
}

output "credentials_json" {
  value       = module.cos.hmac_credentials
  description = "The HMAC credentials JSON for the COS instance."
  sensitive   = true
}

output "bucket_name" {
  description = "The name of the COS bucket."
  value       = module.cos_bucket.cos_bucket_name
}

output "cos_bucket_endpoint" {
  value       = module.cos_bucket.cos_bucket_direct_endpoint
  description = "The direct endpoint of the COS bucket."
}
