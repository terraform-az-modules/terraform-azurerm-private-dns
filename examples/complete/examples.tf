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
  environment = "dev"
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
  name                = "dns"
  environment         = "testing"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Private DNS Zone module call
##-----------------------------------------------------------------------------
module "private_dns" {
  depends_on          = [module.resource_group, module.vnet]
  source              = "../.."
  resource_group_name = module.resource_group.resource_group_name
  private_dns_config = [
    {
      resource_type = "key_vault"
      vnet_ids      = [module.vnet.vnet_id]
    },
    {
      resource_type = "storage_account"
      vnet_ids      = [module.vnet.vnet_id]
    }
  ]

  dns_records = {
    # Records for key_vault private zone
    "key_vault" = [
      {
        name    = "myvault" # This will create myvault.privatelink.vaultcore.azure.net
        type    = "A"
        ttl     = 300
        records = ["10.0.0.10"]
      }
    ],

    # Records for storage_account private zone
    "storage_account" = [
      {
        name    = "mystorage" # This will create mystorage.privatelink.blob.core.windows.net
        type    = "CNAME"
        ttl     = 300
        records = ["mystorage.blob.core.windows.net"]
      },
      {
        name    = "myqueue" # This will create myqueue.privatelink.queue.core.windows.net
        type    = "CNAME"
        ttl     = 300
        records = ["myqueue.queue.core.windows.net"]
      }
    ]
  }

  #Tags
  location    = module.resource_group.resource_group_location
  name        = "dns"
  environment = "dev"
} 