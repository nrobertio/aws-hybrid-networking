variable "spoke_attachments" {
  description = "Map of spoke name to { vpc_id, subnet_ids }."
  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)
  }))
}
variable "egress_vpc_id" { type = string }
variable "egress_subnet_ids" { type = list(string) }
