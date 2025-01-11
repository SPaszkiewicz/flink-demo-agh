data "aws_caller_identity" "current" {}

locals {
  emr_ec2_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/EMR_EC2_DefaultRole"
  emr_core_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EMR_DefaultRole"
}


variable "PUBLIC_SUBNET_CIDRS" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "PRIVATE_SUBNET_CIDRS" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "KAFKA_EC2_CONFIG" {
  type = object({
    instance_type = string
    ami = string
  })

  description = "Kafka base config"

  default = {
    instance_type = "t2.large"
    ami = "ami-022e1a32d3f742bd8"
  }
}

variable "REGION" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "NUM_OF_INSTANCES" {
  type        = number
  description = "Number of ec2 instances in fleet"
  default     = 2
}

variable "EC2_SLAVE_TYPE" {
  type        = string
  description = "Instance type used for fleet workers"
  default     = "m4.xlarge"
}

variable "EC2_MASTER_TYPE" {
  type        = string
  description = "Instance type used for master"
  default     = "m4.xlarge"
}

variable "PROVIDER" {
  type        = string
  description = "Cloud service provider"
  default     = "aws"
}

variable "BUCKET_NAME" {
  type        = string
  description = "Name for bucket"
  default     = "flink-algorithm-storage-instance"
}

variable "KEY_PAIR" {
  type = string
  description = "Key pair to ec2 instance with Apache Kafka"
  default = "vockey"
}