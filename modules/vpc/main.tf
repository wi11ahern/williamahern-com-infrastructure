resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.common_tags, { "Name" : "${local.project_prefix}-VPC" })
}

##### Public Routing #####
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, { "Name" : "${local.project_prefix}-IGW" })
}

resource "aws_subnet" "public_subnets" {
  for_each          = local.cidr_to_public_subnet_map
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value[0]
  availability_zone = each.value[1]

  tags = merge(local.common_tags, { "Name" : "${local.project_prefix}-${each.value[1]}-Public-Subnet" })
}


resource "aws_route_table" "public_route_tables" {
  for_each = local.cidr_to_public_subnet_map

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = merge(local.common_tags, { "Name" : "${local.project_prefix}-Public-Route-Table-${each.key}" })
}

resource "aws_route_table_association" "public_subnet_rt_associations" {
  for_each = local.cidr_to_public_subnet_map

  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_route_tables[each.key].id
}

##### Private Routing #####
resource "aws_subnet" "private_subnets" {
  for_each = local.cidr_to_private_subnet_map

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value[0]
  availability_zone = each.value[1]

  tags = merge(local.common_tags, { "Name" : "${local.project_prefix}-${each.value[1]}-Private-Subnet" })
}
resource "aws_route_table" "private_route_tables" {
  for_each = local.cidr_to_private_subnet_map

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, { "Name" : "${local.project_prefix}-Private-Route-Table-${each.key}" })
}

resource "aws_route_table_association" "private_subnet_rt_associations" {
  for_each = local.cidr_to_private_subnet_map

  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_route_tables[each.key].id
}
