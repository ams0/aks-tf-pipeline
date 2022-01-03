variable "resource_group_name" {
  type = string
}

variable "resource_naming_template" {
  type = string
}

variable "progressive" {
  description = "progressive number"
  type        = number
  default     = "001"
}
variable "location" {
  type = string
}

variable "environ" {
  type = string
}
variable "hub-space" {
  default = ["10.0.0.0/22"]
}

variable "hub-private-subnet-prefix" {
  default = ["10.0.0.0/24"]
}
variable "hub-fw-subnet-prefix" {
  default = ["10.0.1.0/24"]
}

variable "spoke-space" {
  default = ["10.0.4.0/22"]
}
variable "subnet-spoke-cluster-prefix" {
  default = ["10.0.4.0/24"]
}
variable "subnet-spoke-ingress-prefix" {
  default = ["10.0.5.0/25"]
}

variable "tags" {
}