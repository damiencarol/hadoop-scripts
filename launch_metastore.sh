# ******************* PRE LAUNCH ZOOKEEPER **********************
cd ~/zookeeper-3.4.3
./bin/zkServer.sh start
# ******************* MODIF POUR UTILISER LA VERSION 14 **********

export HIVE_VERSION="1.3.0-SNAPSHOT"
export HIVE_HOME="/home/hduser/hive/packaging/target/apache-hive-${HIVE_VERSION}-bin/apache-hive-${HIVE_VERSION}-bin"


#export HADOOP_USER_CLASSPATH_FIRST=true

export HIVE_CONF_DIR="/home/hduser/hive-conf-hdp2_1.1"

export HIVE_AUX_JARS_PATH=/home/hduser/mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar

${HIVE_HOME}/bin/hive --service metastore
