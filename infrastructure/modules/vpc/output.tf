output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_arn" {
  value = aws_subnet.public_subnet.arn
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_arn" {
  value = aws_subnet.private_subnet.arn
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "igw_arn" {
  value = aws_internet_gateway.internet_gateway.arn
}

output "igw_id" {
  value = aws_internet_gateway.internet_gateway.id
}

output "public_route_table_arn" {
  value = aws_route_table.public_route_table.arn
}

output "public_route_table_id" {
  value = aws_route_table.public_route_table.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}