# ##############################################################################
# # Outputs
# ##############################################################################

# #
# # Developer tips:
# #   - Include all relevant outputs from the modules being called in the example
# #

output "cos_instance_id" {
  value       = module.cyber_vault.cos_instance_id
  description = "The ID of the COS instance."
}

output "credentials_json" {
  value       = module.cyber_vault.credentials_json
  description = "The HMAC credentials JSON for the COS instance."
  sensitive   = true
}

output "bucket_name" {
  value = module.cyber_vault.bucket_name
}

output "cos_bucket_endpoint" {
  value       = module.cyber_vault.cos_bucket_endpoint
  description = "The direct endpoint of the COS bucket."
}