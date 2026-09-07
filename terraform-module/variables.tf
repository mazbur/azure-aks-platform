###############################################################################
# General
###############################################################################

variable "create_resource_group" {
  description = "Whether the module should create the resource group. Set to false to deploy into an existing one."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}

variable "location" {
  description = "Azure region the resources are deployed into."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}

###############################################################################
# Network
###############################################################################

variable "vnet_name" {
  description = "Name of the Virtual Network hosting the cluster."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space of the Virtual Network."
  type        = list(string)
}

variable "vnet_subnet_name" {
  description = "Name of the subnet the AKS nodes are placed in."
  type        = string
}

variable "vnet_subnet_address_prefixes" {
  description = "Address prefixes of the AKS node subnet. Must be large enough for the maximum node count."
  type        = list(string)
}

variable "vnet_subnet_service_endpoints" {
  description = "Service endpoints enabled on the AKS node subnet."
  type        = list(string)
  default     = ["Microsoft.KeyVault"]
}

###############################################################################
# AKS - cluster
###############################################################################

variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "aks_cluster_dns_prefix" {
  description = "DNS prefix of the cluster API server. Defaults to the cluster name."
  type        = string
  default     = null
}

variable "aks_cluster_kubernetes_version" {
  description = "Kubernetes version of the control plane. Null lets Azure pick the current default."
  type        = string
  default     = null
}

variable "aks_cluster_sku_tier" {
  description = "Control plane SKU tier. Free has no uptime SLA; use Standard or Premium for anything production facing."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.aks_cluster_sku_tier)
    error_message = "aks_cluster_sku_tier must be one of Free, Standard or Premium."
  }
}

variable "aks_cluster_private_cluster_enabled" {
  description = "Whether the API server is only reachable over a private endpoint."
  type        = bool
  default     = true
}

variable "aks_cluster_private_dns_zone_id" {
  description = "Private DNS zone for a private cluster: \"System\", \"None\", or the resource ID of a bring-your-own zone."
  type        = string
  default     = "System"
}

variable "aks_cluster_private_cluster_public_fqdn_enabled" {
  description = "Whether a private cluster also gets a publicly resolvable FQDN."
  type        = bool
  default     = false
}

variable "aks_cluster_local_account_disabled" {
  description = "Disable the local admin kubeconfig account. Requires AAD RBAC to stay reachable."
  type        = bool
  default     = true

  validation {
    condition     = !var.aks_cluster_local_account_disabled || var.aks_cluster_aad_rbac_enabled
    error_message = "aks_cluster_local_account_disabled requires aks_cluster_aad_rbac_enabled, otherwise nobody can authenticate to the cluster."
  }
}

variable "aks_cluster_oidc_issuer_enabled" {
  description = "Expose an OIDC issuer URL. Required by workload identity."
  type        = bool
  default     = true
}

variable "aks_cluster_workload_identity_enabled" {
  description = "Enable Microsoft Entra Workload ID on the cluster."
  type        = bool
  default     = true

  validation {
    condition     = !var.aks_cluster_workload_identity_enabled || var.aks_cluster_oidc_issuer_enabled
    error_message = "aks_cluster_workload_identity_enabled requires aks_cluster_oidc_issuer_enabled."
  }
}

###############################################################################
# AKS - default node pool
###############################################################################

variable "aks_cluster_default_node_pool_name" {
  description = "Name of the default (system) node pool."
  type        = string
  default     = "system"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{0,11}$", var.aks_cluster_default_node_pool_name))
    error_message = "Node pool names must be lowercase alphanumeric, start with a letter and be at most 12 characters."
  }
}

variable "aks_cluster_default_node_pool_vm_size" {
  description = "VM size of the default node pool."
  type        = string
  default     = "Standard_D4ds_v5"
}

variable "aks_cluster_default_node_pool_os_sku" {
  description = "OS SKU of the default node pool, e.g. AzureLinux or Ubuntu."
  type        = string
  default     = "AzureLinux"
}

variable "aks_cluster_default_node_pool_zones" {
  description = "Availability zones the default node pool spreads across."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "aks_cluster_default_node_pool_auto_scaling_enabled" {
  description = "Enable the cluster autoscaler on the default node pool."
  type        = bool
  default     = true
}

variable "aks_cluster_default_node_pool_node_count" {
  description = "Fixed node count. Only used when autoscaling is disabled."
  type        = number
  default     = 3
}

variable "aks_cluster_default_node_pool_min_count" {
  description = "Autoscaler lower bound. Only used when autoscaling is enabled."
  type        = number
  default     = 3
}

variable "aks_cluster_default_node_pool_max_count" {
  description = "Autoscaler upper bound. Only used when autoscaling is enabled."
  type        = number
  default     = 6

  validation {
    condition     = var.aks_cluster_default_node_pool_max_count >= var.aks_cluster_default_node_pool_min_count
    error_message = "aks_cluster_default_node_pool_max_count must be greater than or equal to aks_cluster_default_node_pool_min_count."
  }
}

variable "aks_cluster_default_node_pool_max_pods" {
  description = "Maximum pods per node."
  type        = number
  default     = 110
}

variable "aks_cluster_default_node_pool_os_disk_size_gb" {
  description = "OS disk size of the default node pool in GB."
  type        = number
  default     = 128
}

variable "aks_cluster_default_node_pool_orchestrator_version" {
  description = "Kubernetes version of the default node pool. Null tracks the control plane version."
  type        = string
  default     = null
}

variable "aks_cluster_default_node_pool_host_encryption_enabled" {
  description = "Encrypt node OS and data disks at the host."
  type        = bool
  default     = true
}

variable "aks_cluster_default_node_pool_node_public_ip_enabled" {
  description = "Assign public IPs to nodes. Should stay false for a private cluster."
  type        = bool
  default     = false
}

variable "aks_cluster_default_node_pool_only_critical_addons_enabled" {
  description = "Taint the default pool with CriticalAddonsOnly so it hosts system pods only."
  type        = bool
  default     = false
}

variable "aks_cluster_default_node_pool_temporary_name_for_rotation" {
  description = "Temporary pool name used when a change forces the default node pool to be recreated in place."
  type        = string
  default     = "tmprotation"
}

variable "aks_cluster_default_node_pool_max_surge" {
  description = "Extra nodes added during an upgrade, e.g. \"33%\". Null leaves the Azure default."
  type        = string
  default     = "33%"
}

###############################################################################
# AKS - node auto provisioning
###############################################################################

variable "aks_cluster_node_provisioning_mode" {
  description = "Node provisioning mode: \"Manual\" for classic node pools, \"Auto\" for Node Auto Provisioning (Karpenter)."
  type        = string
  default     = "Manual"

  validation {
    condition     = contains(["Manual", "Auto"], var.aks_cluster_node_provisioning_mode)
    error_message = "aks_cluster_node_provisioning_mode must be either Manual or Auto."
  }

  validation {
    condition     = var.aks_cluster_node_provisioning_mode != "Auto" || var.aks_cluster_network_data_plane == "cilium"
    error_message = "Node Auto Provisioning requires aks_cluster_network_data_plane = \"cilium\"."
  }
}

variable "aks_cluster_node_provisioning_default_node_pools" {
  description = "Whether AKS manages the default node pools itself (\"Auto\") or you do (\"Manual\"). Only used when node provisioning mode is Auto."
  type        = string
  default     = "Auto"

  validation {
    condition     = contains(["Manual", "Auto"], var.aks_cluster_node_provisioning_default_node_pools)
    error_message = "aks_cluster_node_provisioning_default_node_pools must be either Manual or Auto."
  }
}

###############################################################################
# AKS - identity
###############################################################################

variable "aks_cluster_identity_type" {
  description = "Control plane identity type: SystemAssigned or UserAssigned."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], var.aks_cluster_identity_type)
    error_message = "aks_cluster_identity_type must be either SystemAssigned or UserAssigned."
  }
}

variable "aks_cluster_identity_ids" {
  description = "Resource IDs of the user assigned identities. Required when the identity type is UserAssigned."
  type        = list(string)
  default     = []

  validation {
    condition     = var.aks_cluster_identity_type != "UserAssigned" || length(var.aks_cluster_identity_ids) > 0
    error_message = "aks_cluster_identity_ids must contain at least one identity when aks_cluster_identity_type is UserAssigned."
  }
}

###############################################################################
# AKS - Entra ID / RBAC
###############################################################################

variable "aks_cluster_aad_rbac_enabled" {
  description = "Enable Entra ID (AAD) integration for cluster authentication."
  type        = bool
  default     = true
}

variable "aks_cluster_aad_rbac_tenant_id" {
  description = "Tenant ID used for Entra ID integration. Null uses the tenant of the deploying principal."
  type        = string
  default     = null
}

variable "aks_cluster_aad_rbac_group_ids" {
  description = "Object IDs of the Entra ID groups granted cluster-admin."
  type        = list(string)
  default     = []
}

variable "aks_cluster_azure_rbac_enabled" {
  description = "Use Azure RBAC for Kubernetes authorization instead of in-cluster role bindings."
  type        = bool
  default     = true
}

###############################################################################
# AKS - Key Vault secrets provider
###############################################################################

variable "aks_cluster_key_vault_secrets_provider_enabled" {
  description = "Install the Key Vault secrets store CSI driver addon."
  type        = bool
  default     = true
}

variable "aks_cluster_key_vault_secret_rotation_enabled" {
  description = "Enable automatic secret rotation for the CSI driver."
  type        = bool
  default     = true
}

variable "aks_cluster_key_vault_secret_rotation_interval" {
  description = "Secret rotation poll interval, e.g. \"2m\"."
  type        = string
  default     = "2m"
}

###############################################################################
# AKS - Linux profile
###############################################################################

variable "aks_cluster_linux_admin_username" {
  description = "Admin username on the Linux nodes. Only used when an SSH public key is supplied."
  type        = string
  default     = "azureuser"
}

variable "aks_cluster_linux_ssh_public_key" {
  description = "OpenSSH public key for the node admin user. Null omits the linux_profile block and lets AKS manage its own key."
  type        = string
  default     = null

  validation {
    condition     = var.aks_cluster_linux_ssh_public_key == null || can(regex("^ssh-(rsa|ed25519) ", coalesce(var.aks_cluster_linux_ssh_public_key, "ssh-rsa ")))
    error_message = "aks_cluster_linux_ssh_public_key must be an OpenSSH formatted public key (ssh-rsa or ssh-ed25519)."
  }
}

###############################################################################
# AKS - network profile
###############################################################################

variable "aks_cluster_network_pod_cidr" {
  description = "CIDR the overlay pod IPs are allocated from. Must not overlap the VNet address space."
  type        = string
  default     = "192.168.0.0/16"
}

variable "aks_cluster_network_service_cidr" {
  description = "CIDR for Kubernetes service IPs. Must not overlap the VNet address space or the pod CIDR."
  type        = string
  default     = "172.16.0.0/16"
}

variable "aks_cluster_network_dns_service_ip" {
  description = "IP of the kube-dns service. Null derives the .10 address of the service CIDR."
  type        = string
  default     = null
}

variable "aks_cluster_network_policy" {
  description = "Network policy engine: azure, calico or cilium."
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "calico", "cilium"], var.aks_cluster_network_policy)
    error_message = "aks_cluster_network_policy must be one of azure, calico or cilium."
  }

  validation {
    condition     = var.aks_cluster_network_policy != "cilium" || var.aks_cluster_network_data_plane == "cilium"
    error_message = "aks_cluster_network_policy = \"cilium\" requires aks_cluster_network_data_plane = \"cilium\"."
  }
}

variable "aks_cluster_network_data_plane" {
  description = "Network data plane: azure or cilium."
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "cilium"], var.aks_cluster_network_data_plane)
    error_message = "aks_cluster_network_data_plane must be either azure or cilium."
  }
}

variable "aks_cluster_network_outbound_type" {
  description = "How cluster egress leaves the VNet: loadBalancer, userDefinedRouting, managedNATGateway or userAssignedNATGateway."
  type        = string
  default     = "loadBalancer"

  validation {
    condition = contains(
      ["loadBalancer", "userDefinedRouting", "managedNATGateway", "userAssignedNATGateway"],
      var.aks_cluster_network_outbound_type,
    )
    error_message = "aks_cluster_network_outbound_type must be one of loadBalancer, userDefinedRouting, managedNATGateway or userAssignedNATGateway."
  }
}
