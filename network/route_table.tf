resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "rt_association" {
  count =  length(aws_route_table.public)
  route_table_id = aws_route_table.public.id
  subnet_id = element([for subnet in aws_subnet.public: subnet.id],count.index)
}

resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id
  gateway_id     = aws_internet_gateway.default.id

  destination_cidr_block = "0.0.0.0/0"
}