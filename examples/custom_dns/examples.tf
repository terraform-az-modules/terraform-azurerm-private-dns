provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "app"
  environment = "qa"
  location    = "eastus"
  label_order = ["name", "environment", "location"]
}

##-----------------------------------------------------------------------------
## Vnet module call
##-----------------------------------------------------------------------------
module "vnet" {
  depends_on          = [module.resource_group]
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = "app"
  environment         = "qa"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Private DNS Zone module call
##-----------------------------------------------------------------------------
module "custom_private_dns" {
  depends_on          = [module.resource_group, module.vnet]
  source              = "../.."
  resource_group_name = module.resource_group.resource_group_name
  private_dns_config = [
    {
      resource_type = "custom_dns"
      vnet_ids      = [module.vnet.vnet_id]
      zone_name     = "my.custom.zone.internal"
    }
  ]

  dns_records = {
    "my.custom.zone.internal" = [
      {
        name    = "web"
        type    = "A"
        ttl     = 300
        records = ["10.0.0.5"]
      },
      {
        name    = "db"
        type    = "CNAME"
        ttl     = 300
        records = ["db.internal.example.com"]
      }
    ]
  }

  #Tags
  location    = module.resource_group.resource_group_location
  name        = "app"
  environment = "qa"
}

