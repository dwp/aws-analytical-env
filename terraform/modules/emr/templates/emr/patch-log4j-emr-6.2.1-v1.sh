#!/bin/bash

set -ex

EMR_RELEASE=emr-6.2
DELETE_JNDI_PATH=/var/aws/emr/delete_jndi.sh
MANIFEST_PATCH_PATH=/var/aws/emr/manifest_site.patch
HIVE_INIT_PATCH_PATH=/var/aws/emr/hive_log4j.patch
SITE_PP_PATH=/var/aws/emr/bigtop-deploy/puppet/manifests/site.pp
HIVE_INIT_PATH=/var/aws/emr/bigtop-deploy/puppet/modules/hadoop_hive/manifests/init.pp


function check_release_version {
    CLUSTER_RELEASE=`cat /mnt/var/lib/instance-controller/extraInstanceData.json | jq -r '.releaseLabel' | cut -d "." -f 1,2`
    if [[ "$EMR_RELEASE" != "$CLUSTER_RELEASE" ]]; then
	echo "This script is written for $EMR_RELEASE and this cluster is $CLUSTER_RELEASE. Please use the correct bootstrap script for this release."
	exit 1
    else
	echo "Cluster is $CLUSTER_RELEASE, matches script release $EMR_RELEASE. Proceeding with update."
    fi
}

function create_delete_jndi_script {
    sudo bash -c "cat > $DELETE_JNDI_PATH" <<"EOF"
#/bin/bash

set -e
jars=("/usr/lib/flink/bin/bash-java-utils.jar" "/usr/lib/flink/lib/log4j-core-2.12.1.jar" "/usr/lib/hbase-operator-tools/hbase-hbck2-1.0.0.jar" "/usr/lib/hive/lib/log4j-core-2.10.0.jar" "/usr/lib/hudi/cli/lib/log4j-core-2.10.0.jar" "/usr/lib/presto/plugin/elasticsearch/log4j-core-2.13.3.jar" "/usr/lib/presto/plugin/presto-druid/log4j-core-2.8.2.jar" "/usr/lib/presto/plugin/presto-elasticsearch/log4j-core-2.9.1.jar" "/usr/share/aws/emr/emr-log-analytics-metrics/lib/log4j-core-2.13.3.jar" "/usr/share/aws/emr/emr-metrics-collector/lib/log4j-core-2.11.2.jar")

class="org/apache/logging/log4j/core/lookup/JndiLookup"
jndi="${class}.class"

for index in "${!jars[@]}"; do
  jar=${jars[$index]}
  if [[  -f "$jar" ]]; then
    still_exists=`jar tf $jar | grep -i $class || true`
    if [[ ! -z "$still_exists" ]]; then
      echo "Removing JndiLookup class from $jar..."
      sudo zip -q -d $jar $jndi
      echo "Removed JndiLookup class from $jar."
    fi
  fi
done

remaining_jars=()

for index in "${!jars[@]}"; do
  jar=${jars[$index]}
  if [[ -f "$jar" ]] && jar tf $jar | grep -i $class ; then
    remaining_jars+=$jar
  fi
done

if [[ ${remaining_jars[@]} ]]; then
   echo "[ERROR] JndiLookup class still exists in: "
   printf "%s\n" "${remaining_jars[@]}"
   exit 1
fi

exit 0
EOF

    sudo chmod +x $DELETE_JNDI_PATH
}

function create_manifest_patch {
    sudo bash -c "cat > $MANIFEST_PATCH_PATH" <<"EOF"
--- a/bigtop-deploy/puppet/manifests/site.pp
+++ b/bigtop-deploy/puppet/manifests/site.pp
@@ -107,6 +107,10 @@ node default {
   } else {
     include node_with_components
   }
+
+  class { 'log4j_hotfix':
+    stage => 'pre'
+  }
 }

 if versioncmp($::puppetversion,'3.6.1') >= 0 {
@@ -115,3 +119,22 @@ if versioncmp($::puppetversion,'3.6.1') >= 0 {
     allow_virtual => $allow_virtual_packages,
   }
 }
+
+class log4j_hotfix {
+  if ("hbase-client" in hiera("bigtop::roles")) {
+    include hbase_operator_tools::library
+  }
+
+  exec { 'delete jndi':
+    path    => ['/bin', '/usr/bin', '/usr/sbin',],
+    command => "/bin/bash /var/aws/emr/delete_jndi.sh",
+    logoutput => true
+  }
+
+  exec { 'restart metrics-collector':
+    path    => ['/bin', '/usr/bin', '/usr/sbin',],
+    command => "systemctl restart metricscollector",
+    onlyif  => "systemctl is-active metricscollector",
+    require => [ Exec['delete jndi'] ]
+  }
+}
EOF
}

function create_hive_log4j_patch {
    sudo bash -c "cat > $HIVE_INIT_PATCH_PATH" <<"EOF"
--- a/bigtop-deploy/puppet/modules/hadoop_hive/manifests/init.pp
+++ b/bigtop-deploy/puppet/modules/hadoop_hive/manifests/init.pp
@@ -221,6 +221,12 @@ class hadoop_hive {
       require => Package['hive'],
     }
 
+    exec { 'change log4j loglevel to error':
+      path    => ['/bin', '/usr/bin', '/usr/sbin',],
+      command => "sed -i 's/^status = INFO/status = ERROR/g' /etc/hive/conf/{beeline,hive}-log4j2.properties && ln -sf /etc/hive/conf/hive-log4j2.properties /etc/hadoop/conf",
+      require => [Bigtop_file::Properties['/etc/hive/conf/hive-log4j2.properties'],Bigtop_file::Properties['/etc/hive/conf/beeline-log4j2.properties']]
+    }
+
     bigtop_file::properties { '/etc/hive/conf/hive-exec-log4j2.properties':
       source => '/etc/hive/conf.dist/hive-exec-log4j2.properties.default',
       overrides => $hive_exec_log4j2_overrides,
}
EOF
}

check_release_version
create_delete_jndi_script
create_manifest_patch
create_hive_log4j_patch

sudo patch -p1 -b $SITE_PP_PATH < $MANIFEST_PATCH_PATH
sudo patch -p1 -b $HIVE_INIT_PATH < $HIVE_INIT_PATCH_PATH

touch /tmp/created_jndi_patch
