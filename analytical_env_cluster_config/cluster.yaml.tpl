---
Applications:
- Name: "Spark"
- Name: "Livy"
- Name: "Hive"
CustomAmiId: "${ami}"
EbsRootVolumeSize: 100
LogUri: "s3://${log_bucket}/logs/"
Name: "aws-analytical-env"
ReleaseLabel: "emr-${release_version}"
SecurityConfiguration: "${security_configuration}"
ScaleDownBehavior: "TERMINATE_AT_TASK_COMPLETION"
ServiceRole: "arn:aws:iam::${account}:role/AE_EMR_Role"
JobFlowRole: "arn:aws:iam::${account}:instance-profile/AE_EMR_EC2_Role"
VisibleToAllUsers: True
Tags:
- Key: "Application"
  Value: "aws-analytical-env"
- Key: "AutoShutdown"
  Value: "False"
- Key: "Costcode"
  Value: "${costcode}"
- Key: "CreatedBy"
  Value: "emr-launcher"
- Key: "Environment"
  Value: "${environment}"
- Key: "Name"
  Value: "aws-analytical-env"
- Key: "Owner"
  Value: "dataworks platform"
- Key: "Persistence"
  Value: "True"
- Key: "ProtectSensitiveData"
  Value: "True"
- Key: "SSMEnabled"
  Value: "True"
- Key: "Team"
  Value: "DataWorks"
