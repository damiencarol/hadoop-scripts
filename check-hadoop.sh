#! /bin/bash

export HADOOP_PREFIX="/home/hduser/hadoop-2.6.0"

pr_ok_red()
{
  printf '\e[31m%s\e[m' "error"
}

pr_ok_yellow()
{
  printf '\e[33m%s\e[m' "ok"
}

pr_ok_green()
{
  printf '\e[32m%s\e[m' "ok"
}

function print_host()
{
  printf "HOST $1: "
}

function check_equal()
{
  if [[ $1 == $2 ]]; then
    printf "$2 "
    pr_ok_green
  else
    printf "$1 (= $2) "
    pr_ok_red
  fi
}

function check_greater()
{
  if [[ $1 -gt $2 ]]; then
    printf "$2 "
    pr_ok_green
  else
    printf "$1 (> $2) "
    pr_ok_red
  fi
}

function check_ulimit_n()
{
  printf "Check max number of open files (ulimit -n)... "
  res=$(ssh $1 "ulimit -n")
  check_equal $res 16384
  echo ""
}

function check_swap_zero_size()
{
  printf "Check SWAP size ... "
  res=$(ssh $1 "free -m" | grep Swap | awk 'NF {print $2}')
  printf $res
  printf "MB"
  #check_equal $res 0
  echo ""
}

function check_swap_not_used()
{
  printf "Check SWAP not used ... "
  res=$(ssh $1 "free -m" | grep Swap | awk 'NF {print $3}')
  check_equal $res 0
  echo ""
}

function check_swappiness()
{
  printf "Check swappiness (vm.swappiness) ... "
  res=$(ssh $1 cat /proc/sys/vm/swappiness)
  check_equal $res "0"
  echo ""
}

function check_swappiness_conf()
{  
  printf "Check swappiness (vm.swappiness in sysclt.conf) ... "
  res=$(ssh $1 cat /etc/sysctl.conf | grep vm.swappiness | awk '{ printf $3 }')
  check_equal $res "0"
  echo ""
}

function check_dirty_writeback()
{  
  printf "Check dirty_writeback_centisecs (active parameter) ... "
  res=$(ssh $1 cat /proc/sys/vm/dirty_writeback_centisecs )
  check_equal $res "6000"
  echo ""
}

function check_dirty_writeback_conf()
{  
  printf "Check dirty_writeback_centisecs (vm.dirty_writeback_centisecs in sysclt.conf) ... "
  res=$(ssh $1 cat /etc/sysctl.conf | grep vm.dirty_writeback_centisecs | awk '{ printf $3 }')
  check_equal $res "6000"
  echo ""
}

function check_somaxconn()
{  
  printf "Check somaxconn (active parameter) ... "
  res=$(ssh $1 cat /proc/sys/net/core/somaxconn )
  check_equal $res "512"
  echo ""
}

function check_somaxconn_conf()
{  
  printf "Check somaxconn (net.core.somaxconn in sysclt.conf) ... "
  res=$(ssh $1 cat /etc/sysctl.conf | grep net.core.somaxconn | awk '{ printf $3 }')
  check_equal $res "512"
  echo ""
}

function check_ntptime()
{
  printf "Check NTP (service running) ... "
  #res=$(ssh $1 "service ntpd status" | grep ntp_gettime | awk '{ printf $4 }')
  res=$(ssh $1 "ntpstat" | grep -c "unsynchronised")
  check_equal $res 0
  echo ""
}

function check_ntp()
{
  printf "Check NTP (service stats) ... "
  res=$(ssh $1 ntpstat | grep -c "time correct")
  check_equal $res 1
  echo ""
}

function check_io()
{
  printf "Check IO (running dd) ... "
  #ssh $1 'dd if=/dev/zero of=/home/hduser/bloc2.raw bs=100M count=10'
  
  res=$(ssh $1 'time dd if=/home/hduser/bloc2.raw iflag=direct of=/dev/null bs=1024k count=1024')
  #check_equal $res 0
  echo ""
}

function check_iptables()
{
  printf "Check iptables (not running) ... "
  res=$(ssh $1 "/etc/init.d/iptables status" | grep -c 1)
  check_equal $res 0
  echo ""
}

function check_ipv6()
{
  printf "Check ipv6 disabled (on bond0) ... "
  #res=$(ssh $1 ifconfig bond0 | grep -c inet6)
  res=$(ssh $1 cat /etc/sysconfig/network | grep NETWORKING_IPV6=no)
  check_equal $res "NETWORKING_IPV6=no"
  echo ""
}

function check_hostname()
{
  printf "Check hostname (hostname) ... "
  res=$(ssh $1 'hostname' )
  check_equal $res $1
  echo ""
}

function check_java()
{
  printf "Check JAVA (java -version) ... "
  res=$(ssh $1 java -version 2>&1 | sed 's/java version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q' )
  check_equal $res 17
  echo ""
}

function check_snappy()
{
  printf "Check SNAPPY (ls /usr/lib64*) ... "
  res=$(ssh $1 "ls /usr/lib64/lib*.so*" | grep -c /usr/lib64/libsnappy.so )
  check_greater $res 0
  echo ""
}



function check_selinux_disabled()
{
  printf "Check SELINUX is disabled (currently) ... "
  res=$(ssh $1 "/usr/sbin/sestatus" | grep status | grep -c disabled )
  check_equal $res 1
  echo ""
}

function check_selinux_disabled_conf()
{
  printf "Check SELINUX is disabled (in /etc/sysconfig/selinux) ... "
  res=$(ssh $1 cat /etc/sysconfig/selinux | grep SELINUX=disabled )
  check_equal $res "SELINUX=disabled"
  echo ""
}

function check_hdp_datanode_socketpath()
{
  printf "Check if HDFS socket path exists (/var/lib/hadoop-hdfs) ... "
  res=$(ssh $1 "file /var/lib/hadoop-hdfs" | grep -c "/var/lib/hadoop-hdfs: directory" )
  check_equal $res 1
  echo ""
}

for HDP_HOST in $(cat $HADOOP_PREFIX/etc/hadoop/slaves)
do
  print_host $HDP_HOST
  check_hostname $HDP_HOST
  print_host $HDP_HOST
  check_iptables $HDP_HOST
  print_host $HDP_HOST
  check_ipv6 $HDP_HOST
  print_host $HDP_HOST
  check_ulimit_n $HDP_HOST
  print_host $HDP_HOST
  check_swap_zero_size $HDP_HOST
  print_host $HDP_HOST
  check_swap_not_used $HDP_HOST
  print_host $HDP_HOST
  check_swappiness $HDP_HOST
  print_host $HDP_HOST
  check_swappiness_conf $HDP_HOST
  print_host $HDP_HOST
  check_dirty_writeback $HDP_HOST
  print_host $HDP_HOST
  check_dirty_writeback_conf $HDP_HOST
  print_host $HDP_HOST
  check_somaxconn $HDP_HOST
  print_host $HDP_HOST
  check_somaxconn_conf $HDP_HOST
  print_host $HDP_HOST
  check_ntp $HDP_HOST
  
  
  print_host $HDP_HOST
  check_selinux_disabled $HDP_HOST
  print_host $HDP_HOST
  check_selinux_disabled_conf $HDP_HOST

  print_host $HDP_HOST
  check_java $HDP_HOST
  print_host $HDP_HOST
  check_snappy $HDP_HOST
  print_host $HDP_HOST
  check_hdp_datanode_socketpath $HDP_HOST
  
  
done

echo ""


#for HDP_HOST in $(cat $HADOOP_PREFIX/etc/hadoop/slaves)
#do
#  print_host $HDP_HOST
#
#  check_io $HDP_HOST
#done
#
#echo ""
