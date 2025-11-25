##-----------------------------------------------------------------------------
## Output variables for referencing created DNS zones and links
##-----------------------------------------------------------------------------
output "private_dns_zone_ids" {
  description = "Private DNS Zone IDs for each resource type"
  value = {
    for resource_type, zone in azurerm_private_dns_zone.this : resource_type => zone.id
  }
}

output "private_dns_zone_names" {
  description = "Private DNS Zone names for each resource type"
  value       = local.dns_zone_map
}

##-----------------------------------------------------------------------------
## Custom DNS Zones
##-----------------------------------------------------------------------------
output "custom_dns_zone_ids" {
  description = "IDs of custom DNS zones (when zone_name is provided)"
  value = {
    for cfg in var.private_dns_config :
    cfg.resource_type => try(azurerm_private_dns_zone.this[cfg.resource_type].id, null)
    if try(cfg.zone_name, null) != null
  }
}

output "custom_dns_zone_names" {
  description = "Names of custom DNS zones (when zone_name is provided)"
  value = {
    for cfg in var.private_dns_config :
    cfg.resource_type => cfg.zone_name
    if try(cfg.zone_name, null) != null
  }
}

output "this_name" {
  description = "The resource name"
  value       = azurerm_private_dns_zone.this.name
}

