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

variable "tags" {
  description = "tags"
  default = {
    "madeby"  = "me",
    "madefor" = "me"
  }
}