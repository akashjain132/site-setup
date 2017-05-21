#!/bin/bash

# Help menu
print_help() {
cat <<-HELP
This script is used to Setup a drupal site and fix its permissions.

you need to provide the following arguments:

  1) Path where we want to setup your site.
  2) Username of the user that you want to give files/directories ownership.
  3) HTTPD group name (defaults to www-data for Apache).

Usage: (sudo) bash ${0##*/} --drupal_path=PATH --drupal_user=USER --httpd_group=GROUP
Example: (sudo) bash ${0##*/} --drupal_path=/usr/local/apache2/htdocs --drupal_user=john --httpd_group=www-data
HELP
exit 0
}

if [ $(id -u) != 0 ]; then
  printf "**************************************\n"
  printf "* Error: You must run this with sudo or root*\n"
  printf "**************************************\n"
  print_help
  exit 1
fi

########################
#
# Setting up linux user.
#
#######################
current_user=$SUDO_USER
scriptPath=$(pwd)

# printf "\n###################################\n"
# printf "#\n"
# printf "# Setting up linux user.\n"
# printf "#\n"
# printf "###################################\n"

# echo "Enter Linux user name? "
# while [[ $username = "" ]]; do
#   read username
# done

# if [ ! $(getent passwd $username) ] ; then
#   echo "Enter $username's password "
#   stty_orig=`stty -g`
#   stty -echo
#   while [[ $password = "" ]]; do
#     read password
#   done
#   stty $stty_orig
# fi

# echo "HTTP group name (Default: www-data) "
# read httpd_group
# if [ -z "$httpd_group" ]; then
# httpd_group="www-data"
# fi

# echo "Enter github's repo link (git@github.com:<organization>/<Repo-Name>.git) "
# while [[ $repo = "" ]]; do
#   read repo
# done

# echo "Enter site location (Default: /var/www) "
# read site_location
# if [ -z "$site_location" ]; then
# site_location="/var/www"
# fi

# echo "Enter Folder's name "
# while [[ $folder = "" ]]; do
#   read folder
# done

# if [ ! $(getent passwd $username) ] ; then
#   sudo useradd -m $username -s /bin/bash
#   echo -e "$password\n$password" | passwd $username
# fi

# if [ ! -d "/home/$username/.ssh" ]; then
#   sudo mkdir -p /home/$username/.ssh
# fi

# if [! -f "/home/$username/.ssh/id_rsa" ]; then
#   sudo ssh-keygen -t rsa -N '' -f /home/$username/.ssh/id_rsa
# fi

# printf "\n\n******************************************\n"
# printf "Enter the public key in your Repo and then"
# printf "\n******************************************\n\n"
# cat /home/$username/.ssh/id_rsa.pub
# printf "\n******************************************\n"
# printf "Enter the public key in your Repo and then"
# printf "\n******************************************\n\n"
# read -n 1 -s -p "Press any key to continue"

# printf "Changing owner of $site_location to "${current_user}:${httpd_group}"...\n"
# chown $current_user:$httpd_group $site_location

# cd $site_location
# git clone $repo $folder

########################
#
# Setting up Mysql User.
#
#######################
current_user=$SUDO_USER

printf "\n###################################\n"
printf "#\n"
printf "# Setting up Mysql User.\n"
printf "#\n"
printf "###################################\n"

echo "Enter Mysql username "
while [[ $mysqlUser = "" ]]; do
  read mysqlUser
done

echo "Enter Mysql's password "
stty_orig=`stty -g`
stty -echo
while [[ $mysqlPassword = "" ]]; do
  read mysqlPassword
done
stty $stty_orig

echo "Enter DATABASE Name "
while [[ $database = "" ]]; do
  read database
done

echo "Enter Mysql's root password "
stty_orig=`stty -g`
stty -echo
while [[ $mysqlRootPassword = "" ]]; do
  read mysqlRootPassword
done
stty $stty_orig

echo "Enter myslq host (Default: localhost) "
read MysqlHost
if [ -z "$MysqlHost" ]; then
MysqlHost="localhost"
fi

sudo bash $scriptPath/mysql.sh mysqlUser $mysqlPassword $database $mysqlRootPassword $MysqlHost

###################################
#
# Create Virtual host for the site.
#
###################################

printf "\n###################################\n"
printf "#\n"
printf "# Create Virtual host for the site.\n"
printf "#\n"
printf "###################################\n"

if [ -d "$folder/docroot/sites" ]; then
cd $folder/docroot/sites/Default
WEB_ROOT_DIR=$folder/docroot
fi

if [ -d "$folder/sites" ]; then
cd $folder/sites/Default
WEB_ROOT_DIR=$folder
fi

echo "Enter Site Name "
while [[ $siteName = "" ]]; do
  read siteName
done

echo "Enter Site Aliases "
while [[ $siteAliases = "" ]]; do
  read siteAliases
done

sudo bash $scriptPath/vhost.sh $siteName $siteAliases $WEB_ROOT_DIR

###################################
#
# Setting up drupal site.
#
###################################

printf "\n###################################\n"
printf "#\n"
printf "# Setting up drupal site.\n"
printf "#\n"
printf "###################################\n"

echo "Enter Files folder file path (.tar.gz) "
while [[ $files_folder = "" ]]; do
  read folder
done

echo "Enter Mysql file path (.tar.gz) "
while [[ $mysql_file = "" ]]; do
  read mysql_file
done

cd $WEB_ROOT_DIR/sites/default

cp default.settings.php settings.php

wget $files_folder
tar -zxf $files_folder files_folder.sql
tar -xf $files_folder files_folder.sql
rm files_folder.sql

wget $mysql_file
tar -zxf $mysql_file mysql_file.sql
mysql -uroot -p$mysqlRootPassword $database < mysql_file.sql
rm mysql_file.sql

echo "
      \$databases = array (
        'default' =>
        array (
          'default' =>
          array (
            'database' => '$database',
            'username' => '$mysqlUser',
            'password' => '$mysqlPassword',
            'host' => '$MysqlHost',
            'port' => '',
            'driver' => 'mysql',
            'prefix' => '',
          ),
        ),
      );
      " >> settings.php

sudo bash $scriptPath/fix-permissions.sh --drupal_path=$WEB_ROOT_DIR --drupal_user=$httpd_group

echo "\n\nDone, :)"
