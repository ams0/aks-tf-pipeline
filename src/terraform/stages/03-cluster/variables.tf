variable "intent" {
  description = "keyword describing the purpose of the resources, for example, the name of the project"
  default     = "aks"
}

variable "environment" {
  description = "environment, dev|stage|prod"
  default     = "dev"
}

variable "location" {
  description = "Azure location for the resources"
  default     = "westeurope"
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

variable "tenant_id" {
  description = "Tenant ID for the AAD Authentication domain"
  type        = string
}

variable "admin_group_object_ids" {
}

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
  description = "tags"
  default = {
    "madeby"  = "me",
    "madefor" = "me"
  }
}