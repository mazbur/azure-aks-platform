## Resource group

output "resource_group_name" {
  description = "Name of the resource group holding the platform resources."
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "Region of the resource group holding the platform resources."
  value       = local.location
}

## Network

output "virtual_network_id" {
  description = "Resource ID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "virtual_network_name" {
  description = "Name of the Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_id" {
  description = "Resource ID of the AKS node subnet."
  value       = azurerm_subnet.aks.id
}

## Cluster

output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_fqdn" {
  description = "Public FQDN of the API server. Empty for a private cluster without a public FQDN."
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_cluster_private_fqdn" {
  description = "Private FQDN of the API server."
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "aks_cluster_kubernetes_version" {
  description = "Kubernetes version currently running on the control plane."
  value       = azurerm_kubernetes_cluster.aks.current_kubernetes_version
}

output "aks_cluster_node_resource_group" {
  description = "Auto generated resource group holding the cluster node resources."
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

## Identity

output "aks_cluster_identity_principal_id" {
  description = "Principal ID of the cluster control plane identity."
  value       = try(azurerm_kubernetes_cluster.aks.identity[0].principal_id, null)
}

output "aks_cluster_kubelet_identity_object_id" {
  description = "Object ID of the kubelet identity, e.g. for granting AcrPull."
  value       = try(azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id, null)
}

output "aks_cluster_kubelet_identity_client_id" {
  description = "Client ID of the kubelet identity."
  value       = try(azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id, null)
}

output "aks_cluster_oidc_issuer_url" {
  description = "OIDC issuer URL used to federate workload identities."
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "aks_cluster_key_vault_secrets_provider_identity_client_id" {
  description = "Client ID of the Key Vault secrets provider identity, for Key Vault access policies."
  value       = try(azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].client_id, null)
}

## Credentials

output "aks_cluster_kube_config" {
  description = "Raw kubeconfig for the local admin account. Empty when local accounts are disabled."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}
