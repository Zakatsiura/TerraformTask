variable "project_name" {
  description = "The name of the project"
  type        = string

  validation {
    condition     = length(var.project_name) > 5
    error_message = "Project name must be longer than 5 characters."
  }
}

variable "environment_name" {
  description = "The environment name"
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment_name)
    error_message = "Environment name must be one of 'dev', 'uat', or 'prod'."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = can(regex("^t[0-9]+\\.[a-z]+$", var.instance_type))
    error_message = "Instance type must be a valid t type (e.g., t2.micro)."
  }
}

variable "monitoring" {
  description = "Enable monitoring"
  type        = bool

  validation {
    condition     = var.monitoring == true
    error_message = "Monitoring must be enabled."
  }
}

variable "root_block_device_size" {
  description = "Size of the root block device"
  type        = number

  validation {
    condition     = var.root_block_device_size >= 10 && var.root_block_device_size < 30
    error_message = "Root block device size must be between 10 and 30 GB."
  }
}

variable "ebs_size" {
  description = "Size of the EBS volume"
  type        = number

  validation {
    condition     = var.ebs_size >= 10 && var.ebs_size < 30
    error_message = "EBS size must be between 10 and 30 GB."
  }
}

variable "application_ports" {
  description = "Application ports"
  type        = list(number)

  validation {
    condition     = alltrue([for port in var.application_ports : port >= 1 && port <= 65535])
    error_message = "Application ports must be in the range 1-65535."
  }
}

variable "environment_owner" {
  description = "Email of the environment owner"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.environment_owner))
    error_message = "Environment owner must be a valid email address."
  }
}

variable "ami_id" {
  description = "The ID of the AMI"
  type        = string

  validation {
    condition     = can(regex("^ami-[a-zA-Z0-9]+$", var.ami_id))
    error_message = "AMI ID must be a valid AWS AMI ID."
  }
}