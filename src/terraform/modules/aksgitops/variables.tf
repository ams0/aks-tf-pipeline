variable "resource_group_name" {
  type = string
}

variable "resource_naming_template" {
  type = string
}

variable "upgrade_channel" {
  type    = string
  default = "stable"
}

variable "defaultpool_node_count" {
  type    = string
  default = 3
}

variable "defaultpool_vm_size" {
  type    = string
  default = "Standard_B4ms"
}

variable "kubernetes_version" {
  type    = string
  default = "1.22.2"
}

variable "vnet_subnet_id" {
  type = string
}

#Addons

variable "addon_azure_policy_enabled" {
  type    = bool
  default = true
}

variable "addon_oms_agent_enabled" {
  type    = bool
  default = false
}

variable "addon_azure_keyvault_secrets_provider_enabled" {
  type    = bool
  default = true
}

#Networking
variable "outbound_type" {
  type    = string
  default = "loadBalancer"
}

variable "network_plugin" {
  type    = string
  default = "azure"
}

variable "network_policy" {
  type    = string
  default = "calico"
}

variable "service_cidr" {
  type    = string
  default = "192.168.100.0/24"
}

variable "docker_bridge_cidr" {
  type    = string
  default = "172.17.0.1/16"
}

variable "dns_service_ip" {
  type    = string
  default = "192.168.100.100"
}

variable "tenant_id" {
  description = "Tenant ID for the AAD Authentication domain"
  type        = string
}

variable "admin_group_object_ids" {
}

variable "cluster_identity_type" {
  type    = string
  default = "SystemAssigned"
}


variable "user_assigned_identity_id" {
  type = string
}

# variable "kubelet_user_assigned_identity_id" {
#   type = string
# }

# variable "client_id" {
#   type = string
# }


# variable "object_id" {
#   type = string
# }

#Nodepools
variable "nodepools" {
  type = list(object({
    name                = string,
    vmsize              = string,
    nodecount           = number,
    max_count           = number,
    min_count           = number,
    k8s_version         = string,
    priority            = string,
    eviction_policy     = string,
    enable_auto_scaling = bool,
    vnet_subnet_id      = string,
    availability_zones  = list(string),
    node_labels         = map(string),
    node_taints         = list(string)
  }))
  default = []
}

#gitops parameters

variable "enable_pod_identity" {
  description = "if to deploy the GitOps extension"
  type        = string
  default     = true
}

variable "sp_clientid" {
  type = string
}

variable "sp_client_secret" {
  type = string
}

variable "sp_tenantid" {
  type = string
}


variable "enable_gitops" {
  description = "if to deploy the GitOps extension"
  type        = string
  default     = true
}


variable "ssh_priv_key_base64" {
  description = "SSH Private Key, base64 encoded"
  type        = string
}

variable "git_repo" {
  type = string
}

variable "git_branch" {
  type = string
}

variable "tags" {

}
