##########################
# COS Bucket Outputs
##########################

output "cos_bucket_name" {
  description = "The name of the created COS bucket."
  value       = try(ibm_cos_bucket.cos_bucket[0].bucket_name, null)
}

output "cos_bucket_id" {
  description = "The ID of the created COS bucket."
  value       = try(ibm_cos_bucket.cos_bucket[0].id, null)
}

output "cos_bucket_crn" {
  description = "The CRN of the created COS bucket."
  value       = try(ibm_cos_bucket.cos_bucket[0].crn, null)
}

output "cos_bucket_region" {
  description = "The region location of the COS bucket."
  value       = var.region
}

output "cos_bucket_kms_key_crn" {
  description = "The KMS key CRN used for encryption (if enabled)."
  value       = var.kms_encryption_enabled ? var.kms_key_crn : null
}

output "cos_bucket_direct_endpoint" {
  description = "The public endpoint URL for the created COS bucket based on the management endpoint type."
  value       = try(ibm_cos_bucket.cos_bucket[0].s3_endpoint_direct, null)
}

output "cos_bucket_public_endpoint" {
  description = "The public endpoint URL for the created COS bucket based on the management endpoint type."
  value       = try(ibm_cos_bucket.cos_bucket[0].s3_endpoint_public, null)
}

output "cos_bucket_private_endpoint" {
  description = "The public endpoint URL for the created COS bucket based on the management endpoint type."
  value       = try(ibm_cos_bucket.cos_bucket[0].s3_endpoint_private, null)
}