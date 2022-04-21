# aws-analytical-env
Infrastucure for the AWS Analytical Environment

## EMR Clusters

### Long-running user cluster

The long-running EMR cluster is currently deployed directly by terraform. The cluster is restarted every night by the `taint-emr` Concourse job to apply any outstanding user changes (see `Authorisation and RBAC`).

### User batch cluster

The user batch cluster is deployed by the `emr-launcher`([GitHub](https://github.com/dwp/emr-launcher)) lambda with the configurations in the `batch_cluster_config` directory. The cluster is launched on-demand by Azkaban using the custom DataWorks EMR Jobtype or DataWorks EMR Azkaban plugin. The clusters automatically shut down after a period of inactivity by scheduled Concourse jobs (`<env>-stop-waiting`).

### EMR Security Configurations

As part of the EMR Launcher Lambda, when a Batch EMR cluster is deployed, it has a new security configuration copied from the previous security configuration and associated with the new EMR cluster. As per ([DW-6602](https://projects.ucd.gpn.gov.uk/browse/DW-6602)) and ([DW-6602](https://projects.ucd.gpn.gov.uk/browse/DW-6624)), these security configurations are copied by the EMR Launcher Lambda for the Batch EMR clusters only. The reason for doing this is described in the tickets, but this can mean we have many security configurations. If the number of EMR security configurations reaches the maximum of 600, we will be unable to launch any more EMR clusters. This can lead to outages of the user facing EMR cluster and the batch clusters if these aren't preiodically cleaned up.


### Logging
Both clusters output their logs to the Cloudwatch log group
```
/app/analytical_batch/step_logs
```
The logs from user submitted steps via Azkaban output to  the Cloudwatch log group
```
/aws/emr/azkaban
```

## Authentication

Authentication is mostly handled by Cognito. There are 2 different authentication mechanisms:
    
1. Direct Cognito login with username and password - uses a custom auth flow in Cognito    
2. Federated login using DWP ADFS - bypasses the custom auth flow

### Custom authentication flow

The custom authentication flow([AWS docs](https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-authentication-flow.html#amazon-cognito-user-pools-custom-authentication-flow)) is used for implementing additional security checks on top of the default Cognito ones. This is not needed for federated users. It uses the [dataworks-analytical-custom-auth-flow](https://github.com/dwp/dataworks-analytical-custom-auth-flow) lambdas triggered by Cognito hooks ([aws-analytical-env repo](https://github.com/dwp/aws-analytical-env/blob/master/terraform/deploy/cognito/modules.tf#L13)). 

### Authentication layers

Authentication and authorisation checking happens at multiple points throughout the Analytical Environment:

1. Dataworks Analytical Frontend Service - facilitates the log in flow and stores JWT tokens (valid for 12 hours) in the browser's storage. Without valid credentials, the user will not be able to access the application
2. Orchestration Service - Any request (provision and deprovision environments) made to the orchestration-service needs to include a valid JWT token
3. Guacamole - Once the environment is fully provisioned, the JWT token is verified before establishing the remote desktop from the user's browser to the analytical workspace
4. EMR - The analytical tooling environments have 2 distinct ways of interacting with the EMR cluster: Apache Livy for Spark sessions, and ODBC for Hive sessions:
    1. Apache Livy - JWT verification is performed by an Nginx proxy, which sits in front of the Livy server that runs on EMR - [livy-proxy GitHub Repo](https://github.com/dwp/dataworks-hardened-images/tree/master/livy-proxy)
    2. ODBC/Hive - JWT verification is performed directly by Hive using [Pluggable Authentication](https://docs.cloudera.com/documentation/enterprise/6/6.3/topics/cdh_sg_hiveserver2_security.html#concept_hdt_ngx_nm) - [analytical-env-hive-custom-auth repo](https://github.com/dwp/analytical-env-hive-custom-auth) builds the custom authentication JAR

## Authorisation (RBAC 2.0)

![rbac diagram](https://user-images.githubusercontent.com/55280269/124492503-73b09d80-ddac-11eb-8fa6-b0f2af9ec1be.png)


The RBAC system uses EMR security configurations to assign a unique IAM role for each user for S3 EMRFS requests. At the moment there is no RBAC at the Hive metastore level, so users can see all database and table metadata. RBAC is performed when users try to access data in S3 based on the corresponding IAM role specified in the security configuration. 

Security configurations match a local Linux PAM user to an IAM role, therefore all users must exist as Linux users to be able to access data. All users are set up using a custom EMR step which only runs when the EMR cluster is started. The EMR cluster is restarted by the `taint-emr` job every night to ensure all users exist on the cluster.

The users and permissions are stored in a MySQL database. The database assigns RBAC policies at the user group level, and each user can be assigned to a group to inherit the group's permissions. Currently permissions cannot be attached directly to a user. 

### Sync and 'munge' lambdas

The RBAC sync lambda (#TODO: add link) synchronises the users from the Cognito User Pool to the MySQL database. The lambda is invoked by Concourse (`admin-sync-and-munge/sync-congito-users-<env>`) daily at 23:00 UTC. 

The RBAC 'munge' lambda takes all the access policies for a given user and combines them to the least number of AWS IAM policies, taking into account the resource limits imposed by AWS. The lambda is invoked by Concourse (`admin-sync-and-munge/create-roles-and-munged-policies-<env>`) after the sync job succeeds.


# Upgrading to EMR 6.2.0

There is a requirement for our data products to start using Hive 3 instead of Hive 2. Hive 3 comes bundled with EMR 6.2.0 
along with other upgrades including Spark. Below is a list of steps taken to upgrade Analytical-env and batch to EMR 6.2.0  

1. Make sure you are using an AL2 ami 

2. Point `analytical-env` clusters at the new metastore: `hive_metastore_v2` in `internal-compute` instead of the old one in the configurations.yml   

    The values below should resolve to the new metastore, the details of which are an output of `internal-compute`
    ```    
   "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}?createDatabaseIfNotExist=true"
   "javax.jdo.option.ConnectionUserName": "${hive_metsatore_username}"
   "javax.jdo.option.ConnectionPassword": "${hive_metastore_pwd}"
   ```

3. Alter the security group deployment to the new security group for `hive-metastore-v2`  

    `hive_metastore_sg_id = data.terraform_remote_state.internal_compute.outputs.hive_metastore_v2.security_group.id`


3. Rotate the `analytical-en` user from the `internal-compute` pipeline so that when `analytical-env` or `batch` starts up it can login to the metastore.

4. Make sure to fetch the new Secret as the secret name has changed

    ```
    data "aws_secretsmanager_secret_version" "hive_metastore_password_secret" {
      provider  = aws
      secret_id = "metadata-store-v2-analytical-env"
    }
    ``` 
   
5. Bump the version of sparklyR from 2.4 to 3.0-2.12   
6. Bump the EMR version to 6.2.0 and launch the cluster.   

Make sure that the first time anything uses the metastore it initialises with Hive 3, otherwise it will have to be rebuilt. 
