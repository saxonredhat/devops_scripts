#!/bin/bash
/opt/mysql/bin/mysql -P3306 -h127.0.0.1 -u root -pxxxxxx -e "select version();"
if [ $? -ne 0 ];then
   systemctl start mysqld 
   echo "`date` mysqld is stop,script auto start mysqld" >>/var/log/check_mysqld.log
else
   echo "mysqld is runing!!!"
fi
