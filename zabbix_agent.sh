
#!/bin/bash
#author:CaptainValk 
#mail:alvinharris@foxmail.com

echo ----- step01 下载解压zabbix_agent -----
#加入伪进度条方便定位出现错误的位置

useradd zabbix
cd /home/zabbix
wget https://cdn.zabbix.com/zabbix/binaries/stable/5.0/5.0.22/zabbix_agent-5.0.22-linux-3.0-amd64-static.tar.gz
tar -zxf zabbix_agent-5.0.22-linux-3.0-amd64-static.tar.gz
cd /home/zabbix/bin
ln -s zabbix_sender zabbix_get /usr/bin
cd ../sbin
ln -s zabbix_agentd /usr/sbin/

echo ----- step02 修改配置文件 -----

cd /home/zabbix/conf

sed -i 's#LogFile=/tmp/zabbix_agentd.log#LogFile=/var/log/zabbix/zabbix_agentd.log#' ./zabbix_agentd.conf
sed -i 's#Server=127.0.0.1#Server=hostip#' ./zabbix_agentd.conf
sed -i 's#ServerActive=127.0.0.1#Server=hostip#' ./zabbix_agentd.conf
sed -i 's#Hostname=localhost.localdomain#Hostname='"${HOSTNAME}"'#' ./zabbix_agentd.conf
sed -i "303a Include=/usr/local/conf/zabbix_agentd/*.conf" ./zabbix_agentd.conf
#使其包含此目录下所有自定义监控项的*.conf结尾文件
cp zabbix_agentd.conf  /usr/local/etc/

echo ----- step 03 创建日志保存文件 -----

mkdir /var/log/zabbix/
chown zabbix:zabbix /var/log/zabbix/
chmod 777 /var/log/zabbix/
touch  /var/log/zabbix/zabbix_agentd.log
chmod 777 /var/log/zabbix/zabbix_agentd.log

echo ----- step 04 复制启动文件修改权限 -----

echo "zabbix_agent 10050/tcp" >>/etc/services
echo "zabbix_agent 10050/udp" >>/etc/services
cp /home/zabbix/sbin/zabbix_agentd /etc/init.d
chmod a+x /etc/init.d/zabbix_agentd
touch  /tmp/zabbix_agentd.pid
chmod 777 /tmp/zabbix_agentd.pid
/etc/init.d/zabbix_agentd
ps -ef | grep zabbix_agentd

echo ----- step 05 100% -----
