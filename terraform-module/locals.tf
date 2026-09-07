locals {
  # When the module creates the resource group, reference the created resource so
  # that every other resource gets an implicit dependency on it.
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name
  location            = var.create_resource_group ? azurerm_resource_group.rg[0].location : var.location

  resource_tags = merge(
    {
      ManagedBy = "Terraform"
    },
    var.tags,
  )

  # "System" and "None" are magic values for private_dns_zone_id; anything else is
  # a bring-your-own private DNS zone resource ID.
  private_dns_zone_is_custom = (
    var.aks_cluster_private_dns_zone_id != null &&
    !contains(["system", "none"], lower(coalesce(var.aks_cluster_private_dns_zone_id, "system")))
  )

  # AKS accepts either dns_prefix or dns_prefix_private_cluster, never both. The
  # private variant is only valid for a private cluster with a custom DNS zone.
  dns_prefix             = coalesce(var.aks_cluster_dns_prefix, var.aks_cluster_name)
  use_private_dns_prefix = var.aks_cluster_private_cluster_enabled && local.private_dns_zone_is_custom

  # kube-dns must live inside the service CIDR; .10 is the AKS convention.
  dns_service_ip = coalesce(
    var.aks_cluster_network_dns_service_ip,
    cidrhost(var.aks_cluster_network_service_cidr, 10),
  )
}
