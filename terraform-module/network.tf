## VNet

resource "azurerm_virtual_network" "vnet" {
	name = var.vnet_name
	location = var.location
	resource_group_name = var.resource_group_name

	tags = local.resource_tags

	address_space = var.vnet_address_space
	subnet {
		name = var.vnet_subnet_name
		address_prefixes = var.vnet_subnet_address_prefixes
		private_endpoint_network_policies = "Disabled"
		service_endpoint {
			service = "Microsoft.KeyVault"
		}
	}
}
