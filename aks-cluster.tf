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

resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "aks-teo-cloud-terraform-poc"
  location            = azurerm_resource_group.aksresourcegroup.location
  resource_group_name = azurerm_resource_group.aksresourcegroup.name
  dns_prefix          = "teo-cloud-terraform-poc-k8s"

  addon_profile {
    azure_policy {
         enabled = true
    }

    open_service_mesh {
        enabled = true
    }    
  }

  default_node_pool {
    name            = "default"
    node_count      = 3
    vm_size         = "Standard_D2_v2"
    availability_zones  = ["1", "2", "3"]
    os_disk_size_gb = 30
    vnet_subnet_id = azurerm_subnet.aksdefaultsubnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "kubenet"
    docker_bridge_cidr = "192.17.0.1/16"
    dns_service_ip  = "10.0.0.35"
    load_balancer_sku  =  "Standard"
    outbound_type      = "loadBalancer"
    pod_cidr           = "10.244.0.0/16"
    service_cidr       = "10.0.0.0/16"
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "poc"
  }
}

resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.akscluster]
  filename     = "/tmp/kubeconfig"
  content      = azurerm_kubernetes_cluster.akscluster.kube_config_raw
}