output "vpc_id" { value = aws_vpc.egress.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "nat_gateway_id" { value = aws_nat_gateway.this.id }
