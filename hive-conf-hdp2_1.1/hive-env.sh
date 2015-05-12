# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set Hive and Hadoop environment variables here. These variables can be used
# to control the execution of Hive. It should be used by admins to configure
# the Hive installation (so that users do not have to set environment variables
# or set command line parameters to get correct behavior).
#
# The hive service being invoked (CLI/HWI etc.) is available via the environment
# variable SERVICE


# Hive Client memory usage can be an issue if a large number of clients
# are running at the same time. The flags below have been useful in 
# reducing memory usage:
#
# if [ "$SERVICE" = "cli" ]; then
#   if [ -z "$DEBUG" ]; then
#     export HADOOP_OPTS="$HADOOP_OPTS -XX:NewRatio=12 -Xms10m -XX:MaxHeapFreeRatio=40 -XX:MinHeapFreeRatio=15 -XX:+UseParNewGC -XX:-UseGCOverheadLimit"
#   else
#     export HADOOP_OPTS="$HADOOP_OPTS -XX:NewRatio=12 -Xms10m -XX:MaxHeapFreeRatio=40 -XX:MinHeapFreeRatio=15 -XX:-UseGCOverheadLimit"
#   fi
# fi

# The heap size of the jvm stared by hive shell script can be controlled via:
#
# export HADOOP_HEAPSIZE=1024
#
# Larger heap size may be required when running queries over large number of files or partitions. 
# By default hive shell scripts use a heap size of 256 (MB).  Larger heap size would also be 
# appropriate for hive server (hwi etc).

export HADOOP_USER_CLASSPATH_FIRST=true

# Set HADOOP_HOME to point to a specific hadoop install directory
# HADOOP_HOME=${bin}/../../hadoop
export HADOOP_PREFIX="/home/hduser/hadoop-2.6.0"

# Hive Configuration Directory can be controlled by:
# export HIVE_CONF_DIR=
export HIVE_CONF_DIR="/home/hduser/hive-conf-hdp2_1.1"

# Folder containing extra libraries required for hive compilation/execution can be controlled by:
#export TEZ_CONF_DIR=/home/hduser/tez-0.4.0-incubating/tez-dist/target/tez-0.4.0-incubating/tez-0.4.0-incubating"
#export HIVE_AUX_JARS_PATH=$TEZ_CONF_DIR:$TEZ_INSTALL_DIR/*:$TEZ_INSTALL_DIR/lib/*:/apps/tez-0.4.0-incubating/*:/apps/tez-0.4.0-incubating/lib/*"
#export TEZ_CONF_DIR=/home/hduser/tez-0.4.0-incubating/conf
#export TEZ_JARS=/home/hduser/tez-0.4.0-incubating/tez-dist/target/tez-0.4.0-incubating/tez-0.4.0-incubating
#export HIVE_AUX_JARS_PATH=/home/hduser/apache-hive-0.13.1-bin/hcatalog/share/hcatalog/*:$TEZ_CONF_DIR:$TEZ_INSTALL_DIR/*:$TEZ_INSTALL_DIR/lib/*"

#echo $HIVE_AUX_JARS_PATH
#export HIVE_AUX_JARS_PATH="/home/hduser/postgresql-8.4-703.jdbc4.jar
#export HIVE_AUX_JARS_PATH=/home/hduser/mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar

#export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/spark-1.2.0-bin-hadoop2.4/lib/spark-assembly-1.2.0-hadoop2.4.0.jar
#export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/spark-1.2.0-bin-hadoop2.4/lib/spark-assembly-1.2.0-SNAPSHOT-hadoop2.3.0-cdh5.1.2.jar

# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hive-0.14/hbase-handler/target/hive-hbase-handler-0.14.0.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-annotations-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-checkstyle-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-client-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-common-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-examples-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-hadoop2-compat-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-hadoop-compat-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-it-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-prefix-tree-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-protocol-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-rest-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-server-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-shell-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-testing-util-0.99.2.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/hbase-thrift-0.99.2.jar

# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/htrace-core-3.0.4.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/netty-3.2.4.Final.jar
# export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH:/home/hduser/hbase-0.99.2/lib/netty-all-4.0.23.Final.jar
#export HIVE_AUX_JARS_PATH=/home/hduser/postgresql-8.4-703.jdbc4.jar:/home/hduser/spark/dist/lib/spark-assembly-1.1.0-SNAPSHOT-hadoop2.4.0.jar"
#export HIVE_AUX_JARS_PATH=/home/hduser/postgresql-8.4-703.jdbc4.jar:/home/hduser/spark/dist/lib/spark-assembly-1.2.0-SNAPSHOT-hadoop2.4.0.jar"


