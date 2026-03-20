## -----------------------------------------------------------------------------
## Labels
## -----------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = null
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region (e.g. `eastus`, `westus`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azure-private-dns"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(string)
  default     = ["name", "environment", "location"]
  description = "The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']."
}

variable "managedby" {
  type        = string
  default     = "terraform-az-modules"
  description = "ManagedBy, eg 'terraform-az-modules'."
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

## -----------------------------------------------------------------------------
## Private DNS Configuration
## -----------------------------------------------------------------------------
variable "enable" {
  type        = bool
  default     = true
  description = "Flag to enable or disable the module. Set to false to skip all resources."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group in which private DNS zones will be created."
}

variable "private_dns_config" {
  type = list(object({
    resource_type = string
    vnet_ids      = list(string)
    zone_name     = optional(string)
  }))
  default     = []
  description = <<EOT
List of private DNS zone configurations for supported Azure PaaS services and custom zones.

Each object supports:
- resource_type: (Required) Type of PaaS resource (e.g., 'container_registry', 'key_vault') or 'custom_dns' for custom zones.
- vnet_ids:      (Required) List of VNet resource IDs to link to the private DNS zone.
- zone_name:     (Optional) Custom DNS zone name. Required when resource_type is 'custom_dns'.
                 For Azure services, if not provided, defaults will be used based on resource_type.
EOT

  validation {
    condition = alltrue([
      for cfg in var.private_dns_config :
      (cfg.resource_type == "custom_dns" && cfg.zone_name != null) ||
      (cfg.resource_type != "custom_dns")
    ])
    error_message = "zone_name is required when resource_type is 'custom_dns'."
  }
}

variable "dns_records" {
  type = map(list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  })))
  default     = {}
  description = <<EOT
Map of DNS record configurations for each zone.
Key should be the resource_type (for Azure services) or zone_name (for custom zones).
Each record object contains:
- name:    Record name (relative to the zone)
- type:    Record type (A, CNAME, TXT, etc.)
- ttl:     Time-to-live in seconds
- records: List of record values
EOT
}
