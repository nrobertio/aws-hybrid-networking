resource "aws_ec2_transit_gateway" "this" {
  description                     = "hub-and-spoke tgw"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags                            = { Name = "core-tgw" }
}

resource "aws_ec2_transit_gateway_route_table" "spokes" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags               = { Name = "spokes-rt" }
}

resource "aws_ec2_transit_gateway_route_table" "egress" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags               = { Name = "egress-rt" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  for_each           = var.spoke_attachments
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids
  tags               = { Name = "${each.key}-attach" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = var.egress_vpc_id
  subnet_ids         = var.egress_subnet_ids
  tags               = { Name = "egress-attach" }
}

# Spokes associate to the spokes route table; they reach the internet via egress.
resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  for_each                       = aws_ec2_transit_gateway_vpc_attachment.spoke
  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spokes.id
}

# Default route from spokes to the egress VPC attachment.
resource "aws_ec2_transit_gateway_route" "spoke_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spokes.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
}

# Egress route table learns each spoke CIDR by propagation.
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_to_egress" {
  for_each                       = aws_ec2_transit_gateway_vpc_attachment.spoke
  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress.id
}

resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress.id
}
