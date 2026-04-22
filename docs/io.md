## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| deployment\_mode | Specifies how the infrastructure/resource is deployed | `string` | `"terraform"` | no |
| dns\_records | Map of DNS record configurations for each zone.<br>Key should be the resource\_type (for Azure services) or zone\_name (for custom zones).<br>Each record object contains:<br>- name:    Record name (relative to the zone)<br>- type:    Record type (A, CNAME, TXT, etc.)<br>- ttl:     Time-to-live in seconds<br>- records: List of record values | <pre>map(list(object({<br>    name    = string<br>    type    = string<br>    ttl     = number<br>    records = list(string)<br>  })))</pre> | `{}` | no |
| enable | Flag to enable or disable the module. Set to false to skip all resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| extra\_tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(string)` | `null` | no |
| label\_order | The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']. | `list(string)` | <pre>[<br>  "name",<br>  "environment",<br>  "location"<br>]</pre> | no |
| location | Azure region (e.g. `eastus`, `westus`). | `string` | `"eastus"` | no |
| managedby | ManagedBy, eg 'terraform-az-modules'. | `string` | `"terraform-az-modules"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `null` | no |
| private\_dns\_config | List of private DNS zone configurations for supported Azure PaaS services and custom zones.<br><br>Each object supports:<br>- resource\_type: (Required) Type of PaaS resource (e.g., 'container\_registry', 'key\_vault') or 'custom\_dns' for custom zones.<br>- vnet\_ids:      (Required) List of VNet resource IDs to link to the private DNS zone.<br>- zone\_name:     (Optional) Custom DNS zone name. Required when resource\_type is 'custom\_dns'.<br>                 For Azure services, if not provided, defaults will be used based on resource\_type. | <pre>list(object({<br>    resource_type = string<br>    vnet_ids      = list(string)<br>    zone_name     = optional(string)<br>  }))</pre> | `[]` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/terraform-az-modules/terraform-azure-private-dns"` | no |
| resource\_group\_name | Name of the Azure Resource Group in which private DNS zones will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| custom\_dns\_zone\_ids | IDs of custom DNS zones (when zone\_name is provided) |
| custom\_dns\_zone\_names | Names of custom DNS zones (when zone\_name is provided) |
| private\_dns\_zone\_ids | Private DNS Zone IDs for each resource type |
| private\_dns\_zone\_names | Private DNS Zone names for each resource type |

