resource "aws_instance" "kafka_instance" {
  instance_type = var.KAFKA_EC2_CONFIG.instance_type
  ami           = var.KAFKA_EC2_CONFIG.ami

  vpc_security_group_ids      = [aws_security_group.kafka_access.id]
  subnet_id                   = aws_subnet.private_subnets[0].id
  iam_instance_profile        = "EMR_EC2_DefaultRole"
  associate_public_ip_address = "true"
  key_name                    = var.KEY_PAIR

  user_data = templatefile("scripts/bash/setup-kafka.sh", {
    s3_name = "${aws_s3_object.upload_loader.bucket}"
    region  = "${var.REGION}"
  })

  metadata_options {
    http_endpoint = "enabled"
  }

  depends_on = [
    aws_s3_object.upload_loader
  ]

  tags = {
    Name = "flink-demo-kafka-instance"
  }
}