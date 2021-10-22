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
            SizeInGB: 16384
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType: "${instance_type_master}"
  - InstanceFleetType: "CORE"
    Name: CORE
    TargetOnDemandCapacity: ${core_instance_count}
    InstanceTypeConfigs:
    - EbsConfiguration:
        EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 4096
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType: "${instance_type_core_one}"
    - EbsConfiguration:
        EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 4096
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType:  "${instance_type_core_two}"
    - EbsConfiguration:
        EbsBlockDeviceConfigs:
        - VolumeSpecification:
            SizeInGB: 4096
            VolumeType: "gp2"
          VolumesPerInstance: 1
      InstanceType: "${instance_type_core_three}"
