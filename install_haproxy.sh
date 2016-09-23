#!/bin/bash

# for CentOS-6

conf_file=/etc/haproxy/haproxy.cfg
#local_ip=`ifconfig eth0 | sed -n '/inet /{s/.*addr://;s/ .*//;p}'`

# install haproxy
which haproxy > /dev/null
if [ "$?" != "0" ]; then
  yum -y install haproxy
else
  cp $conf_file /etc/haproxy/haproxy.cfg.bak
fi

# create haproxy config file
echo -e "global\n\tlog 127.0.0.1 local2\n\tchroot /var/lib/haproxy\n\tpidfile /var/run/haproxy.pid\n\tmaxconn 10240\n\tuser haproxy\n\tgroup haproxy\n\tdaemon\n\tstats socket /var/lib/haproxy/stats" > $conf_file
 
echo -e "\ndefaults\n\tlog global\n\toption dontlognull\n\toption httpclose\n\toption redispatch\n\tretries 3\n\ttimeout http-request 10s\n\ttimeout queue 1m\n\ttimeout connect 10s\n\ttimeout client 1m\n\ttimeout server 1m\n\ttimeout check 10s" >> $conf_file

# create listen host
echo -e "\nlisten proxy_pool" >> $conf_file

read -p "Please input bind ip and port, Examples: (*:80) : " bind_ip_port
echo -e "\tbind $bind_ip_port" >> $conf_file

read -p "Please input mode type (http | tcp) : " mode
echo -e "\tmode $mode" >> $conf_file

read -p "Please input balance type (roundrobin | source) : " balance
echo -e "\tbalance $balance" >> $conf_file

read -p "Please input requires backend server quantity : " server_num
for ((i=1;i<=$server_num;i++))
do
  read -p "backend ip and port, Examples: (192.168.1.10 80) : " backend_ip backend_port
  echo -e "\tserver $backend_ip $backend_ip:$backend_port" >> $conf_file
done

# start haproxy service
service haproxy start
chkconfig haproxy on
