resource "aws_s3_bucket" "flow" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "flow" {
  bucket                  = aws_s3_bucket.flow.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_flow_log" "vpc" {
  for_each             = toset(var.vpc_ids)
  log_destination      = aws_s3_bucket.flow.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = each.value
}
