##----------------------------------------------------------------------------
## Outputs
##----------------------------------------------------------------------------
output "dns_zone_id_storage" {
  value = module.private_dns.private_dns_zone_ids.storage_account
}

output "dns_zone_name_storage" {
  value = module.private_dns.private_dns_zone_names.storage_account
}
