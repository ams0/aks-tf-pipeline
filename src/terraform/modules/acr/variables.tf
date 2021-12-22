variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type = string
  default = "Premium"
}

variable "tags" {
}

variable "subnet_id" {
  type = string
}

variable "private_vnet_id" {
  type = string
}

variable "resource_naming_template" {
  type = string
}
