##############################################################################
# Outputs for CBR Zone Module
##############################################################################

output "cbr_zone_id" {
  description = "The ID of the created or existing CBR zone"
  value       = var.use_existing_cbr_zone ? var.existing_zone_id : ibm_cbr_zone.cbr_zone[0].id
}

output "cbr_zone_name" {
  description = "The name of the created or existing CBR zone"
  value       = var.use_existing_cbr_zone ? null : ibm_cbr_zone.cbr_zone[0].name
}

output "cbr_zone_addresses" {
  description = "List of addresses for the CBR zone"
  value = var.use_existing_cbr_zone ? [
    for addr in var.addresses : {
      type  = addr["type"]
      value = addr["value"]
    }
    ] : [
    for addr in ibm_cbr_zone.cbr_zone[0].addresses : {
      type  = addr.type
      value = addr.value
    }
  ]
}

output "cbr_zone_excluded_addresses" {
  description = "List of excluded addresses for the CBR zone"
  value       = var.use_existing_cbr_zone ? var.excluded_addresses : ibm_cbr_zone.cbr_zone[0].excluded
}
