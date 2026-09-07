## VNet

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = local.location
  resource_group_name = local.resource_group_name

  tags = local.resource_tags

  address_space = var.vnet_address_space
}

## Node subnet
#
# Declared as a standalone resource rather than an inline `subnet` block on the
# VNet so that its ID can be handed to the AKS default node pool. The two styles
# are mutually exclusive.

resource "azurerm_subnet" "aks" {
  name                 = var.vnet_subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = var.vnet_subnet_address_prefixes

  private_endpoint_network_policies = "Disabled"

  dynamic "service_endpoint" {
    for_each = toset(var.vnet_subnet_service_endpoints)

    content {
      service = service_endpoint.value
    }
  }
}
