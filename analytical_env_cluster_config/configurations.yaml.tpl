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
    "yarn.nodemanager.remote-app-log-dir": "s3://${log_bucket}/logs/yarn/"
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
    "spark.r.command": "/opt/R/R-3.6.3/bin/Rscript"
    "spark.r.shell.command": "/opt/R/R-3.6.3/bin/R"
    "spark.sql.catalogImplementation": "hive"
    "spark.sql.warehouse.dir": "s3://${config_bucket}/data/external"
- Classification: "spark-hive-site"
  Properties:
    "hive.exec.dynamic.partition.mode": "nonstrict"
    "hive.server2.authentication": "nosasl"
    "hive.support.concurrency": "true"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionPassword": ${hive_metastore_secret_id}
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}"
    "javax.jdo.option.ConnectionUserName": "${hive_metastore_username}"
- Classification: "hive-site"
  Properties:
    "hive.exec.dynamic.partition.mode": "nonstrict"
    "hive.server2.authentication": "nosasl"
    "hive.support.concurrency": "true"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionPassword": ${hive_metastore_secret_id}
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}"
    "javax.jdo.option.ConnectionUserName": "${hive_metastore_username}"
    "hive.metastore.warehouse.dir": "s3://${config_bucket}/data/external"
    "hive.metastore.client.socket.timeout": "10800"
    "hive.strict.checks.cartesian.product": "false"
    "hive.mapred.mode": "nonstrict"
    "hive.default.fileformat": "ORC"
    "hive.exec.orc.default.compress": "ZLIB"
    "hive.exec.orc.encoding.strategy": "SPEED"
    "hive.exec.orc.split.strategy": "HYBRID"
    "hive.exec.orc.zerocopy": "TRUE"
    %{~ if environment == "production" ~}
    "hive.tez.container.size": "32768"
    "hive.tez.java.opts": "-Xmx26214m"
    "hive.auto.convert.join.noconditionaltask.size": "10922"
    "hive.exec.failure.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.post.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.pre.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive_timeline_logging_enabled": "true"
    %{~ endif ~}
- Classification: "emrfs-site"
  Properties:
    "fs.s3.maxRetries": "20"
- Classification: "tez-site"
  Properties:
    "tez.aux.uris": "/libs/"
    "tez.am.resource.memory.mb": "1024"
