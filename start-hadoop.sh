#!/bin/bash

echo "chophan" | sudo -S service ssh start

initialized() {
	if [ ! -z "$(ls -A "$HADOOP_HOME"/data/hdfs/namenode)" ]; then
		return 0
	else
		return 1
	fi
}

initialized
INITIALIZED=$?

if [ "$INITIALIZED" -eq 0 ]; then
	$HADOOP_HOME/sbin/start-dfs.sh
	$HADOOP_HOME/sbin/start-yarn.sh
else
	$HADOOP_HOME/bin/hdfs namenode -format
	
	$HADOOP_HOME/sbin/start-dfs.sh
	$HADOOP_HOME/sbin/start-yarn.sh
	
	$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse
	$HADOOP_HOME/bin/hdfs dfs -mkdir /tmp
	$HADOOP_HOME/bin/hdfs dfs -setfacl -m user:hive:rwx /user/hive/warehouse
	$HADOOP_HOME/bin/hdfs dfs -setfacl -m user:hive:rwx /tmp
	
	$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/spark/lake
	$HADOOP_HOME/bin/hdfs dfs -setfacl -m user:spark:rwx /user/spark/lake
	$HADOOP_HOME/bin/hdfs dfs -setfacl -m user:spark:rwx /user/hive/warehouse
fi

tail -f /dev/null
