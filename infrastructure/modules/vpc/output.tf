output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [
    for k, subnet in aws_subnet.public_subnets : subnet.id
  ]
}

output "private_subnet_ids" {
  value = [
    for k, subnet in aws_subnet.private_subnets : subnet.id
  ]
}

output "igw_arn" {
  value = aws_internet_gateway.internet_gateway.arn
}

output "igw_id" {
  value = aws_internet_gateway.internet_gateway.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "availability_zones" {
  value = toset([local.availability_zones[0], local.availability_zones[1]])
}