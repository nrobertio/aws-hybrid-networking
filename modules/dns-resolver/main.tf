resource "aws_security_group" "resolver" {
  name        = "route53-resolver"
  description = "Allow DNS to and from on-prem"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = var.onprem_cidrs
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.onprem_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Inbound: on-prem resolves records hosted in AWS.
resource "aws_route53_resolver_endpoint" "inbound" {
  name               = "inbound"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.resolver.id]
  dynamic "ip_address" {
    for_each = var.subnet_ids
    content { subnet_id = ip_address.value }
  }
}

# Outbound: AWS forwards on-prem zones to the on-prem resolver.
resource "aws_route53_resolver_endpoint" "outbound" {
  name               = "outbound"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.resolver.id]
  dynamic "ip_address" {
    for_each = var.subnet_ids
    content { subnet_id = ip_address.value }
  }
}

resource "aws_route53_resolver_rule" "onprem" {
  name                 = "forward-onprem"
  domain_name          = var.onprem_domain
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id
  dynamic "target_ip" {
    for_each = var.onprem_resolver_ips
    content { ip = target_ip.value }
  }
}
