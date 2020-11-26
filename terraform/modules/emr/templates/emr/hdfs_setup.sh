#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

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
  sudo -H -u hdfs bash -c "hdfs dfs -mkdir /user/$USER"
  sudo -H -u hdfs bash -c "hdfs dfs -chown -R $USER:$USER /user/$USER"
  sudo -H -u hdfs bash -c "hdfs dfs -chmod 770 /user/$USER"
done

sudo cp /usr/share/java/mariadb-connector-java.jar /usr/lib/spark/jars/

##### Fix up Hive
echo -e "\nexport AWS_STS_REGIONAL_ENDPOINTS=regional" | sudo tee -a /etc/hive/conf/hive-env.sh
chmod 444 /var/aws/emr/userData.json

sudo systemctl stop hive-server2
sleep 5
sudo systemctl start hive-server2

for EACH_GROUP in $${USER_GROUPS[@]}; do
  echo "Creating group DB in S3 for '$EACH_GROUP'"
  str=$(echo $EACH_GROUP | sed -e 's/[^a-zA-Z0-9_]/_/g')
  sudo /bin/hive -e "CREATE DATABASE IF NOT EXISTS $${str}_db LOCATION '$S3_FILE_PATH/$str/$${str}_db'"
done
