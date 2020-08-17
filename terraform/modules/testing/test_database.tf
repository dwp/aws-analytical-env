resource "aws_glue_catalog_database" "test_analytical_dataset_generation" {
  name        = "test_analytical_dataset_generation"
  description = "Database for the Analytical E2E Tests"
}

resource "aws_glue_catalog_database" "test_analytical_metrics_database" {
  name        = var.db_name
  description = "Database for the metrics datasets"
}
