resource "aws_s3_bucket" "s3_bucket" {
  bucket          = var.BUCKET_NAME
  force_destroy   = true

  tags = {
    Name  = "flink-bucket"
  }
}

locals {
  loader_path                 = "${path.root}/loader/loader-2.0.0"
  emr_instances_script_path   = "${path.root}/scripts/bash/setup-emr-instances.sh"
  sidecar_config_path         = "${path.root}/sidecar/config.json"
  sidecar_service_path        = "${path.root}/sidecar/sidecar-service-1.0.0"
}

resource "aws_s3_object" "emr_logs_folder" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "log/"
}

resource "aws_s3_object" "upload_loader" {
  bucket      = aws_s3_bucket.s3_bucket.id
  key         = "loader/loader"
  source      = local.loader_path
  source_hash = filemd5(local.loader_path)
}

resource "aws_s3_object" "upload_emr_instances_config" {
  bucket      = aws_s3_bucket.s3_bucket.id
  key         = "scripts/setup-emr-instances.sh"
  source      = local.emr_instances_script_path
  source_hash = filemd5(local.emr_instances_script_path)
}

resource "aws_s3_object" "upload_sidecar_service" {
  bucket      = aws_s3_bucket.s3_bucket.id
  key         = "sidecar/sidecar-service-1.0.0"
  source      = local.sidecar_service_path
  source_hash = filemd5(local.sidecar_service_path)
}

resource "aws_s3_object" "upload_sidecar_config" {
  bucket      = aws_s3_bucket.s3_bucket.id
  key         = "sidecar/config.json"
  source      = local.sidecar_config_path
  source_hash = filemd5(local.sidecar_config_path)
}

resource "aws_s3_object" "algorithms_folder" {
  bucket      = aws_s3_bucket.s3_bucket.id
  key         = "algorithms/"
}

resource "aws_s3_object" "datasets_folder" {
  bucket      = aws_s3_bucket.s3_bucket.id
  key         = "datasets/"
}
