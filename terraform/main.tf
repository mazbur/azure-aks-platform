## Azure Kubernetes Service

resource "azurerm_kubernetes_service" "aks" {
  
  name = var.aks_cluster_name
  location = var.location
  resource_group_name = var.resource_group_name

  dns_prefix_private_cluster = var.aks_cluster_dns_prefix_private_cluster

  default_node_pool {
    name = var.aks_cluster_default_node_pool_name
    vm_size = var.aks_cluster_default_node_pool_vm_size
    auto_scaling_enabled = var.aks_cluster_default_node_pool_auto_scaling_enabled
    host_encryption_enabled = var.aks_cluster_default_node_pool_host_encryption_enabled
    node_public_ip_enabled = var.aks_cluster_default_node_pool_node_public_ip_enabled
    max_pods = var.aks_cluster_default_node_pool_max_pods
    orchestrator_version = var.aks_cluster_default_node_pool_orchestrator_version
    os_disk_size_gb = var.aks_cluster_default_node_pool_os_disk_size_gb 
    vnet_subnet_id = // TO DO:  Add subnet ID
    max_count = var.aks_cluster_default_node_pool_auto_scaling_enabled ? var.aks_cluster_default_node_pool_max_count: null
    min_count = var.aks_cluster_default_node_pool_auto_scaling_enabled ? var.aks_cluster_default_node_pool_min_count: null
    node_count = var.aks_cluster_default_node_pool_auto_scaling_enabled ? var.aks_cluster_default_node_pool_node_count: null
  }

  node_provisioning_profile {
    default_node_pools = "Auto"
    mode = "Auto"
  }

  identity {
    type = var.aks_cluster_identity_type \\ Either system assigned or user assigned
    identity_ids = var.aks_cluster_indentity_ids \\ List
  }

  azure_active_directory_role_based_access_control {
    tenant_id = var.aks_cluster_aad_rbac_tenant_id
    admin_group_obejct_ids = var.aks_cluster_aad_rbac_group_ids
    azure_rbac_enabled = var.aks_cluster_aad_rbac_enabled
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = var.aks_cluster_kv_secret_provider
  }

  kubernetes_version = var.aks_cluster_kuberntes_version

  linux_profile {
    admin_username = var.aks_cluster_linux_admin_name
    ssh_key {
       key_data = // TO DO: Create a block
    }
  } 

  network_profile {
    network_plugin = "azure"
    network_policy = "azure" 
    network_plugin_mode = "overlay"   
    pod_cidr = // TO DO
    service_cidr = //TO DO
  }

  sku_tier = "Free"
  workload_identity_enabled = true

}
	
