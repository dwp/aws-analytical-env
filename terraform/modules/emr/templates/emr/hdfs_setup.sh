#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

(

  if [[ $(grep "isMaster" /mnt/var/lib/info/instance.json | grep true) ]]; then
    echo "I am a Master"
    IS_MASTER=1
  else
    echo "I am a Slave, exiting"
    exit 0
  fi

  USERS=$(< /opt/dataworks/users)
  USER_GROUPS=$(< /opt/dataworks/groups)
  S3_FILE_PATH=$(echo ${hive_data_s3} | awk -F ':' '{print $3 "://" $6}')

  for USER in $${USERS[@]}; do
    sudo -H -u hdfs bash -c "hdfs dfs -mkdir -p /user/$USER"
    sudo -H -u hdfs bash -c "hdfs dfs -chown -R $USER:$USER /user/$USER"
    sudo -H -u hdfs bash -c "hdfs dfs -chmod 770 /user/$USER"
  done

  sudo cp /usr/share/java/mariadb-connector-java.jar /usr/lib/spark/jars/

  ##### Fix up Hive
  echo -e "\nexport AWS_STS_REGIONAL_ENDPOINTS=regional" | sudo tee -a /etc/hive/conf/hive-env.sh
  echo -e "\nexport HADOOP_HEAPSIZE=${hive_heapsize}" | sudo tee -a /etc/hive/conf/hive-env.sh
  chmod 444 /var/aws/emr/userData.json

  sudo systemctl stop hive-server2
  sleep 5
  sudo systemctl start hive-server2

  #### Fix up Tez
  sudo -H -u hdfs bash -c "hdfs dfs -mkdir -p /libs"
  sudo -H -u hdfs bash -c "hdfs dfs -put /usr/lib/hbase/hbase-client*.jar /libs"
  sudo -H -u hdfs bash -c "hdfs dfs -put /usr/share/java/Hive-JSON-Serde/hive-openx-serde.jar /libs"
  sudo -H -u hdfs bash -c "hdfs dfs -put /usr/lib/hive/lib/hive-serde.jar /libs"

  aws s3 cp s3://${config_bucket}/rbac-teams/team_dbs.json .
  TEAM_DBS="$(cat ./team_dbs.json | jq  'fromjson | .[] | .database')"
  rm team_dbs.json
  for DB in $${TEAM_DBS[@]}; do
      DB=$(echo "$DB" | tr -d '"')
      echo "CREATE DATABASE IF NOT EXISTS $${DB} LOCATION 's3://${published_bucket}/data/$${DB}';" >> create_db.sql
  done
  sudo /bin/hive -f create_db.sql

) >> /var/log/batch/hdfs_setup.log 2>&1
