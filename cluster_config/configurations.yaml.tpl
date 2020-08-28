---
Configurations:
- Classification: "core-site"
  Properties:
    "hadoop.proxyuser.livy.groups": "*"
    "hadoop.proxyuser.livy.hosts": "*"
- Classification: "livy-conf"
  Properties:
    "livy.file.local-dir-whitelist": "/"
    "livy.spark.yarn.security.credentials.hiveserver2.enabled": "true"
    "livy.repl.enable-hive-context": "true"
    "livy.spark.deploy-mode": "cluster"
    "livy.impersonation.enabled": "true"
    "livy.server.port": "8998"
- Classification: "yarn-site"
  Properties:
    "yarn.log-aggregation.retain-seconds": "-1"
    "yarn.log-aggregation-enable": "true"
    "yarn.nodemanager.remote-app-log-dir": "s3://${log_bucket}/logs/yarn/"
- Classification: "spark"
  Properties:
    "maximizeResourceAllocation": "false"
- Classification: "spark-defaults"
  Properties:
    "spark.sql.catalogImplementation": "hive"
    "spark.r.command": "/opt/R/R-3.6.3/bin/Rscript"
    "spark.r.shell.command": "/opt/R/R-3.6.3/bin/R"
    "spark.executor.extraJavaOptions": "-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 -XX:MaxHeapFreeRatio=70 -XX:+CMSClassUnloadingEnabled -XX:OnOutOfMemoryError='kill -9 %p' -Dhttp.proxyHost='${proxy_host}' -Dhttp.proxyPort='3128' -Dhttp.nonProxyHosts='${full_no_proxy}' -Dhttps.proxyHost='${proxy_host}' -Dhttps.proxyPort='3128'"
    "spark.driver.extraJavaOptions": "-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 -XX:MaxHeapFreeRatio=70 -XX:+CMSClassUnloadingEnabled -XX:OnOutOfMemoryError='kill -9 %p' -Dhttp.proxyHost='${proxy_host}' -Dhttp.proxyPort='3128' -Dhttp.nonProxyHosts='${full_no_proxy}' -Dhttps.proxyHost='${proxy_host}' -Dhttps.proxyPort='3128'"
    "spark.sql.warehouse.dir": "s3://${config_bucket}/data/external"
- Classification: "spark-hive-site"
  Properties:
    "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
- Classification: "emrfs-site"
  Properties:
    "fs.s3.consistent.retryPeriodSeconds": "3"
    "fs.s3.consistent": "true"
    "fs.s3.consistent.retryCount": "5"
    "fs.s3.consistent.metadata.tableName": "EmrFSMetadata"
