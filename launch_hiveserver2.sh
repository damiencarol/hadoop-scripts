export HIVE_VERSION="1.3.0-SNAPSHOT"
export HIVE_HOME=/home/hduser/hive/packaging/target/apache-hive-${HIVE_VERSION}-bin/apache-hive-${HIVE_VERSION}-bin


export HIVE_CONF_DIR="/home/hduser/hive-conf-hdp2_1.1"

#export HADOOP_USER_CLASSPATH_FIRST=true

${HIVE_HOME}/bin/hive --service hiveserver2
