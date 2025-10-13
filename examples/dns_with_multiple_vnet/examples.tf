provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azure"
  version     = "1.0.1"
  name        = "app"
  environment = "uat"
  location    = "eastus"
  label_order = ["name", "environment", "location"]
}

##-----------------------------------------------------------------------------
## Vnet module call
##-----------------------------------------------------------------------------
module "vnet1" {
  depends_on          = [module.resource_group]
  source              = "terraform-az-modules/vnet/azure"
  version             = "1.0.1"
  name                = "app1"
  environment         = "uat"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Vnet module call
##-----------------------------------------------------------------------------
module "vnet2" {
  depends_on          = [module.resource_group]
  source              = "terraform-az-modules/vnet/azure"
  version             = "1.0.1"
  name                = "app2"
  environment         = "uat"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Private DNS Zone module call
##-----------------------------------------------------------------------------
module "private_dns" {
  depends_on          = [module.resource_group, module.vnet1, module.vnet2]
  source              = "../.."
  resource_group_name = module.resource_group.resource_group_name
  private_dns_config = [
    {
      resource_type = "storage_account"
      vnet_ids      = [module.vnet1.vnet_id, module.vnet2.vnet_id] # DNS for storage account will get linked to both vnets
    }
  ]
  #Tags
  location    = module.resource_group.resource_group_location
  name        = "dns"
  environment = "dev"
}

