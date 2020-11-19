---
Configurations:
- Classification: "core-site"
  Properties:
    "hadoop.proxyuser.livy.groups": "*"
    "hadoop.proxyuser.livy.hosts": "*"
- Classification: "livy-conf"
  Properties:
    "livy.file.local-dir-whitelist": /
    "livy.impersonation.enabled": "true"
    "livy.repl.enable-hive-context": "true"
    "livy.server.port": "8998"
    "livy.spark.deploy-mode": "cluster"
    "livy.spark.yarn.security.credentials.hiveserver2.enabled": "true"
- Classification: "yarn-site"
  Properties:
    "yarn.log-aggregation-enable": "true"
    "yarn.log-aggregation.retain-seconds": "-1"
    "yarn.nodemanager.remote-app-log-dir": "${logs_bucket_path}/yarn/"
- Classification: "spark"
  Properties:
    "maximizeResourceAllocation": "false"
- Classification: "spark-defaults"
  Properties:
    "spark.driver.extraJavaOptions": "-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70
      -XX:MaxHeapFreeRatio=70 -XX:+CMSClassUnloadingEnabled -XX:OnOutOfMemoryError='kill
      -9 %p' -Dhttp.proxyHost='${proxy_host}' -Dhttp.proxyPort='3128' -Dhttp.nonProxyHosts='${full_no_proxy}'
      -Dhttps.proxyHost='${proxy_host}' -Dhttps.proxyPort='3128'"
    "spark.executor.extraJavaOptions": "-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps
      -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 -XX:MaxHeapFreeRatio=70
      -XX:+CMSClassUnloadingEnabled -XX:OnOutOfMemoryError='kill -9 %p' -Dhttp.proxyHost='${proxy_host}'
      -Dhttp.proxyPort='3128' -Dhttp.nonProxyHosts='${full_no_proxy}' -Dhttps.proxyHost='${proxy_host}'
      -Dhttps.proxyPort='3128'"
    "spark.r.command": "/opt/R/R-${r_version}/bin/Rscript"
    "spark.r.shell.command": "/opt/R/R-${r_version}/bin/R"
    "spark.sql.catalogImplementation": "hive"
    "spark.sql.warehouse.dir": "${data_bucket_path}/external"
- Classification: "spark-hive-site"
  Properties:
    "hive.exec.dynamic.partition.mode": "nonstrict"
    "hive.server2.authentication": "nosasl"
    "hive.support.concurrency": "true"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionPassword": "metadata-store-analytical-env"
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}"
    "javax.jdo.option.ConnectionUserName": "analytical-env"
- Classification: "hive-site"
  Properties:
    "hive.exec.dynamic.partition.mode": "nonstrict"
    "hive.server2.authentication": "nosasl"
    "hive.support.concurrency": "true"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionPassword": "metadata-store-analytical-env"
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}"
    "javax.jdo.option.ConnectionUserName": "analytical-env"
- Classification: "emrfs-site"
  Properties:
    "fs.s3.consistent": "true"
    "fs.s3.consistent.metadata.tableName": "EmrFSMetadata"
    "fs.s3.consistent.retryCount": "5"
    "fs.s3.consistent.retryPeriodSeconds": "3"
