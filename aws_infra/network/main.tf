# 1. VPC 생성
resource "aws_vpc" "aws05-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}vpc"
  }
}
# 2. Public Subnet 생성
resource "aws_subnet" "aws05-public-subnet" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.aws05-vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.prefix}public-subnet-${count.index + 1}"
  }
}
# 3. Private Subnet 생성
resource "aws_subnet" "aws05-private-subnet" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.aws05-vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.prefix}private-subnet-${count.index + 1}"
  }
}
# 4. Internet Gateway 생성
resource "aws_internet_gateway" "aws05-igw" {
  vpc_id = aws_vpc.aws05-vpc.id
  tags = {
    Name = "${var.prefix}igw"
  }
}
# 5. NAT Gateway 생성 및 Public Subnet 하나에만 할당
resource "aws_eip" "aws05-nat-eip" {
  domain = "vpc"
  tags = {
    Name = "${var.prefix}nat-eip"
  }
}
resource "aws_nat_gateway" "aws05-nat-gateway" {
  allocation_id = aws_eip.aws05-nat-eip.id
  subnet_id     = aws_subnet.aws05-public-subnet[0].id
  tags = {
    Name = "${var.prefix}nat-gw"
  }
}
# 6. Route Table 생성 및 라우팅 설정 (Public 1개, Private 2개)
resource "aws_route_table" "aws05-public-rt" {
  vpc_id = aws_vpc.aws05-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws05-igw.id
  }
  tags = {
    Name = "${var.prefix}public-rt"
  }
}
resource "aws_route_table_association" "aws05-public-rt-association" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.aws05-public-subnet[count.index].id
  route_table_id = aws_route_table.aws05-public-rt.id
}
resource "aws_route_table" "aws05-private-rt" {
  count  = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.aws05-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws05-nat-gateway.id
  }
  tags = {
    Name = "${var.prefix}private-rt-${count.index + 1}"
  }
}
resource "aws_route_table_association" "aws05-private-rt-association" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.aws05-private-subnet[count.index].id
  route_table_id = aws_route_table.aws05-private-rt[count.index].id
}
# 7. Security Group 생성 - SSH-SG, HTTP-SG(80, 443(https))
resource "aws_security_group" "aws05-ssh-sg" {
  name        = "${var.prefix}ssh-sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.aws05-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "aws05-http-sg" {
  name        = "${var.prefix}http-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.aws05-vpc.id
  
  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
    }
  }
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}