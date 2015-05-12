export PID_METASTORE=$( netstat -tulpn | grep 9083 | awk '{ print $7 }' | awk -F'[//]' '{ print $1 }' )
#sleep 1000
export PID_HIVESERVER=$( netstat -tulpn | grep 10000 | awk '{ print $7 }' | awk -F'[//]' '{ print $1 }' )
sleep 1

echo "killing hiveserver... $PID_HIVESERVER "
kill -9 $PID_HIVESERVER
sleep 1
echo "killing metastore... $PID_METASTORE "
kill -9 $PID_METASTORE
