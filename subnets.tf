resource "aws_subnet" "this" {
  for_each = {
    "a" = 1
    "b" = 2
    "c" = 3
    "d" = 4
    "e" = 5
    "f" = 6
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.${each.value}.0/24"
  availability_zone = format("%s%s", var.aws_region, each.key)

  tags = merge(local.common_tags, {
    Name = format("%s-%s", var.project, each.key)
  })
}
