# global vars
variable "group_name" {
  description = "The name of WA group"
  type        = string
  default     = "1306"
}

variable "environment_type" {
  description = "Envitoment type for deployment"
  type        = string
  default     = "dev"
}

# network vars
variable "subnet_zones" {
  description = "List of subnet availability zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "subnets_cidr" {
  description = "Subnet map cidr with zones"
  type        = map(any)
  default = {
    "eu-central-1a" = "10.10.1.0/24"
    "eu-central-1b" = "10.10.2.0/24"
  }
}
