variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "progressive" {
  description = "progressive number"
  type        = number
  default     = "001"
}

variable "tags" {
}

variable "subnet_id" {
  type = string
}

variable "private_vnet_id" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "resource_naming_template" {
  type = string
}
