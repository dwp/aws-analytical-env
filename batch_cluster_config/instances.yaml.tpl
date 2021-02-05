---
Instances:
  KeepJobFlowAliveWhenNoSteps: True
  AdditionalMasterSecurityGroups:
  - "${common_security_group}"
  AdditionalSlaveSecurityGroups:
  - "${common_security_group}"
  Ec2SubnetIds: ${jsonencode(split(",", subnet_ids))}
  EmrManagedMasterSecurityGroup: "${master_security_group}"
  EmrManagedSlaveSecurityGroup: "${slave_security_group}"
  ServiceAccessSecurityGroup: "${service_security_group}"
  InstanceFleets:
  - InstanceFleetType: "MASTER"
    Name: MASTER
    TargetOnDemandCapacity: 1
    InstanceTypeConfigs:
    - EbsConfiguration:
        EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 250
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType: "m5.2xlarge"
  - InstanceFleetType: "CORE"
    Name: CORE
    TargetOnDemandCapacity: ${core_instance_count}
    InstanceTypeConfigs:
    - EbsConfiguration:
        EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 250
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType: "m5.2xlarge"
    - EbsConfiguration:
        EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 250
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType: "m5a.2xlarge"
    - EbsConfiguration:
        EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 250
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType: "m5d.2xlarge"
