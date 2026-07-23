variable "project_name" {
  description = "Prefix used for naming all resources"
  type        = string
  default     = "secure-cloud-infra"
}

variable "location" {
  description = "Azure region to deploy into"
  type        = string
  default     = "swedencentral"
}

variable "vm_size" {
  description = "Azure VM SKU"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "admin_username" {
  description = "SSH admin username for both VMs"
  type        = string
  default     = "azureadmin"
}

variable "vnet_address_space" {
  description = "CIDR block for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_prefix" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "portfolio-demo"
}
