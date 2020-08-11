resource "aws_glue_catalog_database" "test_analytical_dataset_generation" {
  name        = "test_analytical_dataset_generation"
  description = "Database for the Analytical E2E Tests"
}

resource "template_file" "create_metrics_data_template" {
  template = file("${path.module}/${var.create_metrics_data_lambda_file_path}/create_metrics_data_lambda.py")

  vars = {
    dataset_s3_name = var.dataset_s3.id,
    dataset_s3_arn  = var.dataset_s3.arn,
    path_to_folder  = var.s3_path,
    db_name         = var.db_name
  }
}
