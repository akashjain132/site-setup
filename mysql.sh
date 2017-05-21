#!/bin/bash

mysqlUser=$1
if [ -z "$1" ] then
  echo "Enter Mysql username "
  while [[ $mysqlUser = "" ]]; do
    read mysqlUser
  done
fi

mysqlPassword=$2
if [ -z "$2" ] then
  echo "Enter Mysql's password "
  stty_orig=`stty -g`
  stty -echo
  while [[ $mysqlPassword = "" ]]; do
    read mysqlPassword
  done
  stty $stty_orig
fi

database=$3
if [ -z "$3" ] then
  echo "Enter DATABASE Name "
  while [[ $database = "" ]]; do
    read database
  done
fi

mysqlRootPassword=$4
if [ -z "$4" ] then
  echo "Enter Mysql's root password "
  while [[ $mysqlRootPassword = "" ]]; do
    read mysqlRootPassword
  done
fi

SQL="CREATE DATABASE IF NOT EXISTS $database;"
SQL="$SQL CREATE USER '$mysqlUser'@'localhost' IDENTIFIED BY '$mysqlPassword';"
SQL="$SQL GRANT ALL PRIVILEGES ON $database . * TO '$mysqlUser'@'localhost';"
SQL="$SQL FLUSH PRIVILEGES;"

## Execute all operation ##
mysql -uroot -p$mysqlRootPassword -e $SQL

echo "Database is ready now!!"
