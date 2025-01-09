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
  default     = "postgres"
}

resource "aws_security_group" "postgres_sg" {
  name        = "postgres_access"
  description = "Allow inbound PostgreSQL traffic"
  vpc_id      = aws_vpc.main.id

ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
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
    POSTGRES_PASSWORD = "postgres"
  })

  tags = {
    Name = "flink-postgres-ec2-instance"
  }
}
