##----------------------------------------------------------------------------
## Outputs
##----------------------------------------------------------------------------
output "dns_zone_id" {
  value = module.custom_private_dns.custom_dns_zone_ids
}

output "dns_zone_name" {
  value = module.custom_private_dns.custom_dns_zone_names
}
