variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "azs" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "flow_log_bucket" {
  type = string
}

variable "onprem_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "onprem_resolver_ips" {
  type    = list(string)
  default = ["10.0.0.2"]
}