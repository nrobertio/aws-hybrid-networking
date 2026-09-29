module "spoke_dev" {
  source          = "../../modules/vpc"
  name            = "spoke-dev"
  cidr            = "10.10.0.0/16"
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  azs             = var.azs
}

module "spoke_prod" {
  source          = "../../modules/vpc"
  name            = "spoke-prod"
  cidr            = "10.20.0.0/16"
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24"]
  azs             = var.azs
}

module "egress" {
  source         = "../../modules/egress"
  cidr           = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs            = var.azs
}

module "tgw" {
  source = "../../modules/tgw"
  spoke_attachments = {
    dev  = { vpc_id = module.spoke_dev.vpc_id, subnet_ids = module.spoke_dev.private_subnet_ids }
    prod = { vpc_id = module.spoke_prod.vpc_id, subnet_ids = module.spoke_prod.private_subnet_ids }
  }
  egress_vpc_id     = module.egress.vpc_id
  egress_subnet_ids = module.egress.public_subnet_ids
}

module "dns" {
  source              = "../../modules/dns-resolver"
  vpc_id              = module.spoke_dev.vpc_id
  subnet_ids          = module.spoke_dev.private_subnet_ids
  onprem_cidrs        = var.onprem_cidrs
  onprem_resolver_ips = var.onprem_resolver_ips
}

module "flow_logs" {
  source      = "../../modules/flow-logs"
  bucket_name = var.flow_log_bucket
  vpc_ids     = [module.spoke_dev.vpc_id, module.spoke_prod.vpc_id, module.egress.vpc_id]
}
