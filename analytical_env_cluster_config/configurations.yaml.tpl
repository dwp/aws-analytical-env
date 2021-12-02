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
    "yarn.resourcemanager.scheduler.class": "org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler
    "yarn.scheduler.fair.preemption": "true"
    "yarn.scheduler.minimum-allocation-mb": "2048"
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
    %{~ if environment == "production" ~}
    "hive.tez.container.size": "12288"
    "hive.tez.java.opts": "-Xmx9830m"
    "hive.auto.convert.join.noconditionaltask.size": "100000"
    "hive.mapjoin.smalltable.filesize": "2500000"
    "hive.exec.failure.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.post.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.pre.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive_timeline_logging_enabled": "true"
    %{~ endif ~}
    "hive.convert.join.bucket.mapjoin.tez": "false"
    "hive.metastore.schema.verification": "false"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "${hive_compaction_threads}"
    "hive.exec.parallel": "true"
    "hive.vectorized.execution.enabled": "false"
    "hive.vectorized.execution.reduce.enabled": "false"
    "hive.vectorized.complex.types.enabled": "false"
    "hive.vectorized.use.row.serde.deserialize": "false"
    "hive.vectorized.execution.ptf.enabled": "false"
    "hive.vectorized.row.serde.inputformat.excludes": ""
    "hive.server2.tez.sessions.per.default.queue": "${hive_tez_sessions_per_queue}"
    "hive.server2.tez.initialize.default.sessions": "false"
    "hive.default.fileformat": "TextFile"
    "hive.default.fileformat.managed": "ORC"
    "hive.exec.orc.split.strategy": "HYBRID"
    "hive.merge.orcfile.stripe.level": "true"
    "hive.orc.compute.splits.num.threads": "10"
    "hive.orc.splits.include.file.footer": "true"
    "hive.compactor.abortedtxn.threshold": "1000"
    "hive.compactor.check.interval": "300"
    "hive.compactor.delta.num.threshold": "10"
    "hive.compactor.delta.pct.threshold": "0.1f"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "1"
    "hive.compactor.worker.timeout": "86400"
    "hive.blobstore.optimizations.enabled": "true"
    "hive.blobstore.use.blobstore.as.scratchdir": "false"
    "hive.server2.tez.session.lifetime": "0"
    "hive.exec.reducers.max": "${hive_max_reducers}"
    "hive.server2.session.check.interval": "0"
    "hive.server2.idle.operation.timeout": "0"
    "hive.server2.idle.session.timeout": "0"
    "hive.exec.max.dynamic.partitions.pernode": "1000"
- Classification: "emrfs-site"
  Properties:
    "fs.s3.maxRetries": "20"
- Classification: "tez-site"
  Properties:
    "tez.aux.uris": "/libs/"
    "tez.am.resource.memory.mb": "2048"
    "tez.runtime.io.sort.mb" : "4820"
    "tez.runtime.unordered.output.buffer.size-mb": "1228"
