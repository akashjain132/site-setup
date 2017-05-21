#!/bin/bash

siteName=$1
if [ -z "$1" ] then
  echo "Enter Site Name "
  while [[ $siteName = "" ]]; do
    read siteName
  done
fi

siteAliases=$2
if [ -z "$2" ] then
echo "Enter Site Aliases "
while [[ $siteAliases = "" ]]; do
  read siteAliases
done
fi

WEB_ROOT_DIR=$3
if [ -z "$3" ] then
  echo "Enter web root DIR "
  while [[ $WEB_ROOT_DIR = "" ]]; do
    read WEB_ROOT_DIR
  done
fi

sitesEnable='/etc/apache2/sites-enabled/'
sitesAvailable='/etc/apache2/sites-available/'
sitesAvailabledomain=$sitesAvailable$siteName.conf
echo "Creating a vhost for $sitesAvailabledomain with a webroot $WEB_ROOT_DIR"

### create virtual host rules file
echo "
    <VirtualHost *:80>
      ServerAdmin webmaster@localhost
      ServerName $siteName
      ServerAlias $siteAliases
      DocumentRoot $WEB_ROOT_DIR
      <Directory $WEB_ROOT_DIR/>
        Options Indexes FollowSymLinks
        AllowOverride all
      </Directory>
    </VirtualHost>" > $sitesAvailabledomain
echo -e $"\nNew Virtual Host Created\n"

sed -i "1s/^/127.0.0.1 $siteName\n/" /etc/hosts

a2ensite $siteName
sudo service apache2 reload
