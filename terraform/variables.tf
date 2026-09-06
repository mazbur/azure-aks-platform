variable "create_resource_group" {
  description = "Wheteher you want to create resource group?"
  type = boolean
  default = true
}
variable "resource_group_name" {
  description = "Name of the Resource Group"
  type = string
}
variable "location" {
  description = "Location where resoruce will be deployed"
  type = string
}
