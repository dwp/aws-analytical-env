locals {
  name           = replace(var.name, "-", "")
  files_api_path = "/api/contents"
}
