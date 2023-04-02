output "jenkins_server_public_ip" {
  description = "publiic ip address for Jenkins server "
  value       = aws_instance.jenkins_server.public_ip
}

output "s3_bucket_name" {
  description = "Jenkins S3 bucket name"
  value       = aws_s3_bucket.jenkins_artifacts_s3.bucket
}

output "s3_bucket_arn" {
  description = "Jenkins S3 bucket arn"
  value       = aws_s3_bucket.jenkins_artifacts_s3.arn
}
