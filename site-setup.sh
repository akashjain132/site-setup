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

##############################
#
# Get Inputs from user.
#
##############################
current_user=$SUDO_USER

echo "Enter Linux user name? "
while [[ $username = "" ]]; do
  read username
done

echo "Enter $username's password "
stty_orig=`stty -g`
stty -echo
while [[ $password = "" ]]; do
  read password
done
stty $stty_orig

echo "HTTP group name (Default: www-data) "
read httpd_group
if [ -z "$httpd_group" ]; then
httpd_group="www-data"
fi

echo "Enter github's repo link (git@github.com:<organization>/<Repo-Name>.git) "
while [[ $repo = "" ]]; do
  read repo
done

echo "Enter github's username "
while [[ $github_username = "" ]]; do
  read github_username
done

echo "Enter github's password "
stty_orig=`stty -g`
stty -echo
while [[ $github_password = "" ]]; do
  read github_password
done
stty $stty_orig

echo "Enter site location (Default: /var/www) "
read site_location
if [ -z "$site_location" ]; then
site_location="/var/www"
fi

echo "Enter Folder's name "
while [[ $folder = "" ]]; do
  read folder
done

sudo useradd -m $username -s /bin/bash
echo -e "$password\n$password" | passwd $username

sudo mkdir -p /home/$username/.ssh

sudo ssh-keygen -t rsa -N '' -f /home/$username/.ssh/id_rsa

printf "\n\n******************************************\n"
printf "Enter the public key in your Repo and then"
printf "\n******************************************\n\n"
cat /home/$username/.ssh/id_rsa.pub
printf "\n******************************************\n"
printf "Enter the public key in your Repo and then"
printf "\n******************************************\n\n"
read -n 1 -s -p "Press any key to continue"

printf "Changing owner of $site_location to "${current_user}:${httpd_group}"...\n"
chown $current_user:$httpd_group $site_location

cd $site_location
git clone $repo $folder

cd $folder
