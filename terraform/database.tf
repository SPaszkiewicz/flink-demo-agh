data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

variable "POSTGRES_INSTANCE_TYPE" {
  description = "EC2 instance type for PostgreSQL"
  type        = string
  default     = "t3.micro"
}

variable "POSTGRES_PASSWORD" {
  description = "Password for the default postgres superuser"
  type        = string
  sensitive   = true
  default     = "FlinkPassword123"
}

resource "aws_security_group" "postgres_sg" {
  name        = "postgres_access"
  description = "Allow inbound PostgreSQL traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL inbound"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgres_access"
  }
}

resource "aws_instance" "postgres_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.POSTGRES_INSTANCE_TYPE

  subnet_id              = aws_subnet.private_subnets[0].id
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]

  user_data = templatefile("scripts/bash/setup-database.sh", {
    POSTGRES_PASSWORD = "FlinkPassword123"
  })

  tags = {
    Name = "flink-postgres-ec2-instance"
  }
}
