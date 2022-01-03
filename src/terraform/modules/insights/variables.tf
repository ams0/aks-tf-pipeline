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

variable "resource_naming_template" {
  type = string
}

variable "tags" {
}

variable "keyvault_id" {
  type = string
}