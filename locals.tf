##----------------------------------------------------------------------------
## Locals
##----------------------------------------------------------------------------
locals {
  dns_zone_map = {
    key_vault                 = "privatelink.vaultcore.azure.net"
    storage_account           = "privatelink.blob.core.windows.net"
    container_registry        = "privatelink.azurecr.io"
    sql_server                = "privatelink.database.windows.net"
    postgresql_server         = "privatelink.postgres.database.azure.com"
    mysql_server              = "privatelink.mysql.database.azure.com"
    cosmos_db                 = "privatelink.documents.azure.com"
    cosmos_db_mongo           = "privatelink.mongo.cosmos.azure.com"
    cosmos_db_cassandra       = "privatelink.cassandra.cosmos.azure.com"
    cosmos_db_gremlin         = "privatelink.gremlin.cosmos.azure.com"
    cosmos_db_table           = "privatelink.table.cosmos.azure.com"
    synapse_analytics         = "privatelink.sql.azuresynapse.net"
    event_hub                 = "privatelink.servicebus.windows.net"
    service_bus               = "privatelink.servicebus.windows.net"
    azure_ai_services         = "privatelink.cognitiveservices.azure.com"
    azure_file                = "privatelink.file.core.windows.net"
    azure_data_lake           = "privatelink.dfs.core.windows.net"
    azure_monitor             = "privatelink.monitor.azure.com"
    azure_backup              = "privatelink.backup.windowsazure.com"
    azure_site_recovery       = "privatelink.siterecovery.windowsazure.com"
    azure_automation          = "privatelink.agentsvc.azure-automation.net"
    azure_machine_learning    = "privatelink.api.azureml.ms"
    azure_kubernetes          = "privatelink.${var.location}.azmk8s.io"
    azure_redis               = "privatelink.redis.cache.windows.net"
    azure_search              = "privatelink.search.windows.net"
    azure_sql_sync            = "privatelink.database.windows.net"
    azure_data_factory        = "privatelink.datafactory.azure.net"
    azure_data_factory_portal = "privatelink.adf.azure.com"
    azure_event_grid          = "privatelink.eventgrid.azure.net"
    azure_relay               = "privatelink.servicebus.windows.net"
    azure_app_config          = "privatelink.azconfig.io"
    azure_purview             = "privatelink.purview.azure.com"
    azure_purview_studio      = "privatelink.purviewstudio.azure.com"
    azure_batch               = "privatelink.${var.location}.batch.azure.com"
    azure_web_apps            = "privatelink.azurewebsites.net"
    azure_function_apps       = "privatelink.azurewebsites.net"
    azure_api_management      = "privatelink.azure-api.net"
    azure_signalr             = "privatelink.service.signalr.net"
    azure_iot_hub             = "privatelink.azure-devices.net"
    azure_digital_twins       = "privatelink.digitaltwins.azure.net"
    azure_video_indexer       = "privatelink.api.videoindexer.ai"
    # Catch-all for custom DNS zones
    custom_dns = null
  }

  zone_configs = {
    for cfg in var.private_dns_config :
    cfg.resource_type => cfg
    if contains(keys(local.dns_zone_map), cfg.resource_type) || cfg.zone_name != null
  }

  resource_vnets = {
    for cfg in var.private_dns_config :
    cfg.resource_type => cfg.vnet_ids
    if contains(keys(local.dns_zone_map), cfg.resource_type) || cfg.zone_name != null
  }

  dns_vnet_link_map = {
    for pair in flatten([
      for resource_type, vnet_ids in local.resource_vnets : [
        for idx, vnet_id in vnet_ids : {
          key           = "${resource_type}-${idx}"
          resource_type = resource_type
          vnet_id       = vnet_id
          zone_name     = [for cfg in var.private_dns_config : cfg.zone_name if cfg.resource_type == resource_type][0]
        }
      ]
    ]) : pair.key => pair
  }

  a_records = flatten([
    for zone_key, records in var.dns_records : [
      for record in records : merge(record, {
        zone_key  = zone_key
        zone_name = try(local.dns_zone_map[zone_key], zone_key) # Use zone_key directly for custom zones
      }) if record.type == "A"
    ]
  ])

  cname_records = flatten([
    for zone_key, records in var.dns_records : [
      for record in records : merge(record, {
        zone_key  = zone_key
        zone_name = try(local.dns_zone_map[zone_key], zone_key) # Use zone_key directly for custom zones
      }) if record.type == "CNAME"
    ]
  ])

  mx_records = flatten([
    for zone_key, records in var.dns_records : [
      for record in records : merge(record, {
        zone_key  = zone_key
        zone_name = try(local.dns_zone_map[zone_key], zone_key)
        records = [for r in record.records : {
          preference = r.preference
          exchange   = r.exchange
        }]
      }) if record.type == "MX"
    ]
  ])

  txt_records = flatten([
    for zone_key, records in var.dns_records : [
      for record in records : merge(record, {
        zone_key  = zone_key
        zone_name = try(local.dns_zone_map[zone_key], zone_key)
      }) if record.type == "TXT"
    ]
  ])

  srv_records = flatten([
    for zone_key, records in var.dns_records : [
      for record in records : merge(record, {
        zone_key  = zone_key
        zone_name = try(local.dns_zone_map[zone_key], zone_key)
        records = [for r in record.records : {
          priority = r.priority
          weight   = r.weight
          port     = r.port
          target   = r.target
        }]
      }) if record.type == "SRV"
    ]
  ])

  ptr_records = flatten([
    for zone_key, records in var.dns_records : [
      for record in records : merge(record, {
        zone_key  = zone_key
        zone_name = try(local.dns_zone_map[zone_key], zone_key)
      }) if record.type == "PTR"
    ]
  ])

}