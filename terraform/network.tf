resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Flink demo VPC"
  }
}

resource "aws_subnet" "public_subnets" {
  count      = length(var.PUBLIC_SUBNET_CIDRS)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.PUBLIC_SUBNET_CIDRS, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
 count      = length(var.PRIVATE_SUBNET_CIDRS)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.PRIVATE_SUBNET_CIDRS, count.index)
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

resource "aws_internet_gateway" "flink_demo_main_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "VPC IG"
  }
}

resource "aws_route_table" "flink_demo_rt_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.flink_demo_main_gateway.id
  }

}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.flink_demo_rt_public.id
}

resource "aws_security_group" "allow_access_emr" {
  name        = "allow_access_emr"
  description = "Allow any inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_access_emr"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow shh traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "kafka_access" {
  name        = "kafka_access"
  description = "Allow any inbound traffic"
  vpc_id      = aws_vpc.main.id


  ingress {
    description      = "Allow any"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kafka_access"
  }
}