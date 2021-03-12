# aws-analytical-env
Infrastucure for the AWS Analytical Environment


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
