## Azure Kubernetes Service

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = local.location
  resource_group_name = local.resource_group_name

  tags = local.resource_tags

  dns_prefix                 = local.use_private_dns_prefix ? null : local.dns_prefix
  dns_prefix_private_cluster = local.use_private_dns_prefix ? local.dns_prefix : null

  kubernetes_version = var.aks_cluster_kubernetes_version
  sku_tier           = var.aks_cluster_sku_tier

  private_cluster_enabled             = var.aks_cluster_private_cluster_enabled
  private_dns_zone_id                 = var.aks_cluster_private_cluster_enabled ? var.aks_cluster_private_dns_zone_id : null
  private_cluster_public_fqdn_enabled = var.aks_cluster_private_cluster_enabled ? var.aks_cluster_private_cluster_public_fqdn_enabled : false

  local_account_disabled    = var.aks_cluster_local_account_disabled
  oidc_issuer_enabled       = var.aks_cluster_oidc_issuer_enabled
  workload_identity_enabled = var.aks_cluster_workload_identity_enabled

  default_node_pool {
    name                         = var.aks_cluster_default_node_pool_name
    vm_size                      = var.aks_cluster_default_node_pool_vm_size
    os_sku                       = var.aks_cluster_default_node_pool_os_sku
    zones                        = var.aks_cluster_default_node_pool_zones
    vnet_subnet_id               = azurerm_subnet.aks.id
    auto_scaling_enabled         = var.aks_cluster_default_node_pool_auto_scaling_enabled
    host_encryption_enabled      = var.aks_cluster_default_node_pool_host_encryption_enabled
    node_public_ip_enabled       = var.aks_cluster_default_node_pool_node_public_ip_enabled
    only_critical_addons_enabled = var.aks_cluster_default_node_pool_only_critical_addons_enabled
    max_pods                     = var.aks_cluster_default_node_pool_max_pods
    orchestrator_version         = var.aks_cluster_default_node_pool_orchestrator_version
    os_disk_size_gb              = var.aks_cluster_default_node_pool_os_disk_size_gb
    temporary_name_for_rotation  = var.aks_cluster_default_node_pool_temporary_name_for_rotation

    # min/max only apply with the autoscaler on; node_count is the fixed size when
    # it is off (leaving it unset while autoscaling avoids perpetual drift).
    max_count  = var.aks_cluster_default_node_pool_auto_scaling_enabled ? var.aks_cluster_default_node_pool_max_count : null
    min_count  = var.aks_cluster_default_node_pool_auto_scaling_enabled ? var.aks_cluster_default_node_pool_min_count : null
    node_count = var.aks_cluster_default_node_pool_auto_scaling_enabled ? null : var.aks_cluster_default_node_pool_node_count

    tags = local.resource_tags

    dynamic "upgrade_settings" {
      for_each = var.aks_cluster_default_node_pool_max_surge == null ? [] : [1]

      content {
        max_surge = var.aks_cluster_default_node_pool_max_surge
      }
    }
  }

  # Node Auto Provisioning (Karpenter). Only emitted when explicitly turned on --
  # "Auto" mode requires the Cilium data plane and Azure CNI overlay.
  dynamic "node_provisioning_profile" {
    for_each = var.aks_cluster_node_provisioning_mode == "Auto" ? [1] : []

    content {
      default_node_pools = var.aks_cluster_node_provisioning_default_node_pools
      mode               = "Auto"
    }
  }

  identity {
    type = var.aks_cluster_identity_type

    # Only valid -- and mandatory -- when the identity type is UserAssigned.
    identity_ids = var.aks_cluster_identity_type == "UserAssigned" ? var.aks_cluster_identity_ids : null
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.aks_cluster_aad_rbac_enabled ? [1] : []

    content {
      tenant_id              = var.aks_cluster_aad_rbac_tenant_id
      admin_group_object_ids = var.aks_cluster_aad_rbac_group_ids
      azure_rbac_enabled     = var.aks_cluster_azure_rbac_enabled
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.aks_cluster_key_vault_secrets_provider_enabled ? [1] : []

    content {
      secret_rotation_enabled  = var.aks_cluster_key_vault_secret_rotation_enabled
      secret_rotation_interval = var.aks_cluster_key_vault_secret_rotation_interval
    }
  }

  # linux_profile is what pins the node SSH key; without a key AKS generates its
  # own and the block must be omitted entirely.
  dynamic "linux_profile" {
    for_each = var.aks_cluster_linux_ssh_public_key == null ? [] : [1]

    content {
      admin_username = var.aks_cluster_linux_admin_username

      ssh_key {
        key_data = var.aks_cluster_linux_ssh_public_key
      }
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = var.aks_cluster_network_policy
    network_data_plane  = var.aks_cluster_network_data_plane
    pod_cidr            = var.aks_cluster_network_pod_cidr
    service_cidr        = var.aks_cluster_network_service_cidr
    dns_service_ip      = local.dns_service_ip
    outbound_type       = var.aks_cluster_network_outbound_type
    load_balancer_sku   = "standard"
  }
}
