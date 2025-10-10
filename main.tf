##-----------------------------------------------------------------------------
## Tagging Module – Applies standard tags to all resources
##-----------------------------------------------------------------------------
module "labels" {
  source          = "terraform-az-modules/labels/azure"
  version         = "1.0.0"
  name            = var.name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

##----------------------------------------------------------------------------
## Resource – Private DNS Zones for supported Azure PaaS services
##----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "this" {
  for_each            = var.enable ? local.zone_configs : {}
  name                = each.value.zone_name != null ? each.value.zone_name : local.dns_zone_map[each.key]
  resource_group_name = var.resource_group_name
  tags                = module.labels.tags
}

## ----------------------------------------------------------------------------
## Resource – VNet Links to Private DNS Zones
##----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  depends_on            = [azurerm_private_dns_zone.this]
  for_each              = var.enable ? local.dns_vnet_link_map : {}
  name                  = "${replace(basename(each.value.vnet_id), ".", "-")}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.zone_name != null ? each.value.zone_name : local.dns_zone_map[each.value.resource_type]
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------
## Resource – DNS records (A, CNAME, MX, TXT, SRV, PTR) for Private DNS Zones
##----------------------------------------------------------------------------
resource "azurerm_private_dns_a_record" "this" {
  depends_on = [azurerm_private_dns_zone.this]
  for_each = var.enable ? {
    for record in local.a_records : "${record.zone_key}-${record.name}" => record
  } : {}
  name                = each.value.name
  zone_name           = each.value.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = module.labels.tags
}

resource "azurerm_private_dns_cname_record" "this" {
  depends_on = [azurerm_private_dns_zone.this]
  for_each = var.enable ? {
    for record in local.cname_records : "${record.zone_key}-${record.name}" => record
  } : {}
  name                = each.value.name
  zone_name           = each.value.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  record              = each.value.records[0] # CNAME only allows one value
  tags                = module.labels.tags
}

resource "azurerm_private_dns_mx_record" "this" {
  depends_on = [azurerm_private_dns_zone.this]
  for_each = var.enable ? {
    for record in local.mx_records : "${record.zone_key}-${record.name}" => record
  } : {}
  name                = each.value.name
  zone_name           = each.value.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  dynamic "record" {
    for_each = each.value.records
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
  tags = module.labels.tags
}

resource "azurerm_private_dns_txt_record" "this" {
  depends_on = [azurerm_private_dns_zone.this]
  for_each = var.enable ? {
    for record in local.txt_records : "${record.zone_key}-${record.name}" => record
  } : {}
  name                = each.value.name
  zone_name           = each.value.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  dynamic "record" {
    for_each = each.value.records
    content {
      value = record.value
    }
  }
  tags = module.labels.tags
}

resource "azurerm_private_dns_srv_record" "this" {
  depends_on = [azurerm_private_dns_zone.this]
  for_each = var.enable ? {
    for record in local.srv_records : "${record.zone_key}-${record.name}" => record
  } : {}
  name                = each.value.name
  zone_name           = each.value.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  dynamic "record" {
    for_each = each.value.records
    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
  tags = module.labels.tags
}

resource "azurerm_private_dns_ptr_record" "this" {
  depends_on = [azurerm_private_dns_zone.this]
  for_each = var.enable ? {
    for record in local.ptr_records : "${record.zone_key}-${record.name}" => record
  } : {}
  name                = each.value.name
  zone_name           = each.value.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = module.labels.tags
}