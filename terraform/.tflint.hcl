rule aws_resource_missing_tags {
  enabled = true
  tags    = ["Name", "Environment", "Application"]
}
