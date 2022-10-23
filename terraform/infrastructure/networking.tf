data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_subnet_a" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "eu-central-1a"
}

data "aws_subnet" "default_subnet_b" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "eu-central-1b"
}

data "aws_subnet" "default_subnet_c" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "eu-central-1c"
}

resource "aws_vpc" "main" {
  cidr_block           = module.env.network.vpc.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "main"
    Env  = module.env.name
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet-gw"
    Env  = module.env.name
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    Name = "public-rt"
    Env  = module.env.name
  }
}

# NOTE: Create only single nat gateway, otherwise we may run out of EIP addresses
resource "aws_eip" "nat_a" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gw]
  tags = {
    Name = "nat-a"
    Env  = module.env.name
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = module.env.network.public_subnet_a.cidr_block
  availability_zone       = module.env.network.public_subnet_a.availability_zone
  map_public_ip_on_launch = "true"

  tags = {
    Name   = module.env.network.public_subnet_a.name
    Env    = module.env.name
    Region = module.env.network.public_subnet_a.human_readable_region
  }
}

resource "aws_route_table_association" "public_rt_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = module.env.network.public_subnet_b.cidr_block
  availability_zone       = module.env.network.public_subnet_b.availability_zone
  map_public_ip_on_launch = "true"

  tags = {
    Name   = module.env.network.public_subnet_b.name
    Env    = module.env.name
    Region = module.env.network.public_subnet_b.human_readable_region
  }
}

resource "aws_route_table_association" "public_rt_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = module.env.network.public_subnet_c.cidr_block
  availability_zone       = module.env.network.public_subnet_c.availability_zone
  map_public_ip_on_launch = "true"

  tags = {
    Name   = module.env.network.public_subnet_c.name
    Env    = module.env.name
    Region = module.env.network.public_subnet_c.human_readable_region
  }
}

resource "aws_route_table_association" "public_rt_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_subnet_a.id
  depends_on    = [aws_internet_gateway.internet_gw]
  tags = {
    Name = "nat-gw-a"
    Env  = module.env.name
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = module.env.network.private_subnet_a.cidr_block
  availability_zone       = module.env.network.private_subnet_a.availability_zone
  map_public_ip_on_launch = "false"

  tags = {
    Name   = module.env.network.private_subnet_a.name
    Env    = module.env.name
    Region = module.env.network.private_subnet_a.human_readable_region
  }
}

resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_a.id
  }
  tags = {
    Name = "private-rt-a"
    Env  = module.env.name
  }
}

resource "aws_route_table_association" "private_rt_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = module.env.network.private_subnet_b.cidr_block
  availability_zone       = module.env.network.private_subnet_b.availability_zone
  map_public_ip_on_launch = "false"

  tags = {
    Name   = module.env.network.private_subnet_b.name
    Env    = module.env.name
    Region = module.env.network.private_subnet_b.human_readable_region
  }
}

resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    # NOTE: use nat gateway on public network `a`
    nat_gateway_id = aws_nat_gateway.nat_gw_a.id
  }
  tags = {
    Name = "private-rt-b"
    Env  = module.env.name
  }
}

resource "aws_route_table_association" "private_rt_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt_b.id
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = module.env.network.private_subnet_c.cidr_block
  availability_zone       = module.env.network.private_subnet_c.availability_zone
  map_public_ip_on_launch = "false"

  tags = {
    Name   = module.env.network.private_subnet_c.name
    Env    = module.env.name
    Region = module.env.network.private_subnet_c.human_readable_region
  }
}

resource "aws_route_table" "private_rt_c" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    # NOTE: use nat gateway on public network `a`
    nat_gateway_id = aws_nat_gateway.nat_gw_a.id
  }
  tags = {
    Name = "private-rt-c"
    Env  = module.env.name
  }
}

resource "aws_route_table_association" "private_rt_c" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private_rt_c.id
}
