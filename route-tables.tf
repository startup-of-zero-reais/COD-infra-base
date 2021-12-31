resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = format("igw-%s", var.project)
  })
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.common_tags, {
    Name = format("rtb-%s", var.project)
  })
}

resource "aws_route_table_association" "this" {
  for_each = {
    "a" = 1
    "b" = 2
    "c" = 3
    "d" = 4
    "e" = 5
    "f" = 6
  }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this.id
}
