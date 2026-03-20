provider "azurerm" {
  features {}
}

module "private-dns" {
  source = "../../"
}
