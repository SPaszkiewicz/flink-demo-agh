output "emr_id" {
  value = aws_emr_cluster.cluster.id
}

output "kafka_ip" {
  value = aws_instance.kafka_instance.public_ip
}

output "postgres_ip" {
  value       = aws_instance.postgres_instance.public_ip
}
