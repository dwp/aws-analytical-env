The modules in this directory are focused on:

Module Name | Description
------------|------------
alb | Application Load Balancer for the frontend application.
aurora_db | Creation and setup of the RBAC Aurora database.
check-user-expiry-lambda | Lambda that emails user if their account is due to expire.
codecommit | AWS CodeCommit was used as a POC to provide version control for the environment, its no longer used as we use enterprise github.
cognito-fs | Cognito user pool setup including SAML for federated access (ADFS), includes a lambda that stores changes to the pool in S3 secure logs location.
custom_auth_flow | Sets up the [Cognito lambda hooks](https://github.com/dwp/dataworks-analytical-custom-auth-flow) (Pre Auth/Post Auth/Verify etc) for our user pool.
data_user_roles | Python scripts to generate the user -> IAM role mappings for security configuration.
emr-launcher | Sets up a lambda to call the [EMR launcher](https://github.com/dwp/emr-launcher) lambda with defaults for the batch cluster.
emr | Scripts for setting up users and software on the EMR.
emrfs-lamda | Contains the Policy Munge lambda which concatenates policies for a user to get around 10 policy limit.
jupyter-s3-storage | Sets up the bucket to store user home/shared directories. Originally Jupyter specific but now used by all other containers.
livy-proxy | [Service](https://github.com/dwp/dataworks-hardened-images/tree/master/livy-proxy) that sits in front of livy and rewrites requests to prevent impersonation.
networking | Routing information to connect the EMR to an internet gateway and DKS.
pushgateway | Prometheus push-gateway setup to send metric to, currently only used by JupyterHub.
squid_proxy | Internet proxy between user-environment and internet, uses a whitelist to limit internet access.
testing | QA test that checks that deployed EMRs can run both Livy and HiverServer2 requests successfully.
waf | WAF rules for the analytical environment.
