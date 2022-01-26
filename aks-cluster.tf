provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aksresourcegroup" {
  name     = "rg-teo-cloud-terraform-poc"
  location = "West Europe"

  tags = {
    environment = "poc"
  }
}

resource "azurerm_virtual_network" "aksvnet" {
name                = "vnet-teo-cloud-terraform-poc"
resource_group_name =  azurerm_resource_group.aksresourcegroup.name
location            = azurerm_resource_group.aksresourcegroup.location
address_space       = ["172.17.8.0/24"]
}

resource "azurerm_subnet" "aksdefaultsubnet" {
name                    = "snet-teo-cloud-terraform-poc-default"
resource_group_name     = azurerm_resource_group.aksresourcegroup.name
virtual_network_name    = "${azurerm_virtual_network.aksvnet.name}"
address_prefixes          = ["172.17.8.0/25"]
}

