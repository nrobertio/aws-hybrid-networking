variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "onprem_cidrs" { type = list(string) }
variable "onprem_resolver_ips" { type = list(string) }

variable "onprem_domain" {
  type    = string
  default = "corp.example.com"
}