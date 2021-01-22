---
Instances:
  KeepJobFlowAliveWhenNoSteps: True
  AdditionalMasterSecurityGroups:
  - "${common_security_group}"
  AdditionalSlaveSecurityGroups:
  - "${common_security_group}"
  Ec2SubnetIds: ${aws_subnets_private}
  EmrManagedMasterSecurityGroup: "${master_security_group}"
  EmrManagedSlaveSecurityGroup: "${slave_security_group}"
  ServiceAccessSecurityGroup: "${service_security_group}"
  InstanceGroups:
  - Name: CORE
    InstanceCount: 1
    InstanceType: "m5.2xlarge"
    InstanceRole: "CORE"
    EbsConfiguration:
      EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 250
            VolumeType: "gp2"
          VolumesPerInstance: 1
  - Name: MASTER
    InstanceCount: 1
    InstanceType: "m5.2xlarge"
    InstanceRole: "MASTER"
    EbsConfiguration:
      EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 250
            VolumeType: "gp2"
          VolumesPerInstance: 1
