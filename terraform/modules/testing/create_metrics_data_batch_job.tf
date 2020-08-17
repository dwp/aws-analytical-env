resource "aws_batch_compute_environment" "create_metrics_data_environment" {
  service_role                    = aws_iam_role.service_role_for_create_metrics_data_batch.arn
  type                            = "MANAGED"
  depends_on                      = [aws_iam_role_policy_attachment.create_metrics_data_batch_service_role_attachment]
  compute_resources {
    image_id = data.aws_ami.hardened.id
    instance_role = aws_iam_instance_profile.create_metrics_data_instance_profile.arn
    instance_type = [
      "optimal"
    ]
    min_vcpus = 0
    desired_vcpus = 0
    max_vcpus = 8
    security_group_ids = [
      aws_security_group.batch_job_sg.id]
    subnets = [var.subnets[0]]
    type = "EC2"
  }
  compute_environment_name = "${var.name_prefix}-create-metrics-data-environment"
}

resource "aws_batch_job_queue" "create_metrics_data_job_queue" {
  name = "${var.name_prefix}-create-metrics-data-job-queue"
  state = "ENABLED"
  priority = "1"
  compute_environments = [
    aws_batch_compute_environment.create_metrics_data_environment.arn
  ]
}

resource "aws_batch_job_definition" "create_metrics_data_batch_job" {
  name = "${var.name_prefix}-create-metrics-data-batch-job"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
    {
        "jobRoleArn": "${aws_iam_role.job_role_for_create_metrics_data_batch.arn}",
        "image": "dwpdigital/create_metrics_data_batch",
        "memory": 1024,
        "vcpus": 1,
        "environment": [
            { "name": "path_to_folder", "value" : "${var.create_metrics_data_file_path}"},
            { "name": "db_name", "value" : "${var.db_name}"},
            { "name": "dataset_s3_name", "value" : "${var.dataset_s3.id}"}
        ]
    }
  CONTAINER_PROPERTIES
}
