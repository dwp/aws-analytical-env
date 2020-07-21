resource "aws_codecommit_repository" "datascience_codecommit_repository" {
  repository_name = var.repository_name
  description     = var.repository_description

  tags = var.common_tags
}
