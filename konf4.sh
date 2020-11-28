#!/bin/bash
clear
START=$(date +%s)
echo "============================================"
echo "		uuendame systeemi(1/7)			 	  "
echo "============================================"
set echo off
dnf update -y
set echo on
echo "============================================"
echo "		Systeem uuendatud (1/7)				  "
echo "============================================"
echo "============================================"
echo "		installime apache(2/7)			      "
echo "============================================"
set echo off
dnf install httpd httpd-tools -y
systemctl enable httpd
systemctl start httpd
set echo on
echo "============================================"
echo "		apache installitud (2/7)	          "
echo "============================================"
#systemctl status httpd
echo "============================================"
echo "		tulemyyri reeglid (3/7)				  "
echo "============================================"
set echo off
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
set echo on
echo "============================================"
echo "		tulemyyri reeglid (3/7) loodud		  "
echo "============================================"
echo "============================================"
echo "		installime mariadb (4/7)		      "
echo "============================================"
set echo off
dnf install mariadb-server mariadb -y
set echo on
SECURE_MYSQL=$(expect -c "crea

set timeout 10
spawn mysql_secure_installation

expect \"Press y|Y for Yes, any other key for No: \"
send \"n\r\"
expect \"Change the password for root ? ((Press y|Y for Yes, any other key for No) : \"
send \"n\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) : \"
send \"y\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) : \"
send \"y\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) : \"
send \"y\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) : \"
send \"y\r\"
")
EOF

echo "$SECURE_MYSQL"
systemctl start mariadb
systemctl enable mariadb
echo "============================================"
echo "		mariadb installitud (4/7)           "
echo "============================================"
date
#systemctl status mariadb
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# A non-interactive replacement for mysql_secure_installation
#
# Tested on CentOS 6, CentOS 7, Ubuntu 12.04 LTS (Precise Pangolin), Ubuntu
# 14.04 LTS (Trusty Tahr).
mysql -u root <<EOF 
CREATE DATABASE wordpress;
GRANT ALL ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';
flush privileges;
exit 
EOF

echo "============================================"
echo "		Installime PHP 7 (5/7)		          "
echo "============================================"
set echo off
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
set echo on
echo "============================================"
echo "		PHP 7 installitud (5/7)		          "
echo "============================================"
echo "============================================"
echo "		installime moodulid php-le (6/7)	  "
echo "============================================"
set echo off
dnf install httpd-tools php php-cli php-json php-gd php-mbstring php-pdo php-xml php-mysqlnd php-pecl-zip wget tar -y
set echo on
echo info.php faili sisu:
cat > /var/www/html/info.php <<EOF
<?php
phpinfo();
EOF
cat /var/www/html/info.php
systemctl start php-fpm
systemctl enable php-fpm
#systemctl status php-fpm
setsebool -P httpd_execmem 1
systemctl restart httpd
set echo off
cd /var/www
dnf install policycoreutils-python-utils -y
set echo on
echo "============================================"
echo "		php moodulid installitud (6/7)        "
echo "============================================"
echo "============================================"
echo "      Installime Wordpressi (7/7)	          "
echo "============================================"
curl -O https://wordpress.org/latest.tar.gz
set echo off
tar -zxvf latest.tar.gz
#copy file to parent dir
cp -rf wordpress/* .
sudo chown -Rf apache:apache ./wordpress/
chmod -Rf 775 ./wordpress/
semanage fcontext -a -t httpd_sys_rw_content_t \
"/var/www/wordpress(/.*)?"
sudo restorecon -Rv /var/www/wordpress
cat > /etc/httpd/conf.d/wordpress.conf <<EOF
<VirtualHost *:80>
ServerAdmin root@localhost
DocumentRoot /var/www/wordpress
<Directory "/var/www/wordpress">
Options Indexes FollowSymLinks
AllowOverride all
Require all granted
</Directory>
ErrorLog /var/log/httpd/wordpress_error.log
CustomLog /var/log/httpd/wordpress_access.log common
</VirtualHost>
EOF
systemctl restart httpd
#remove files from wordpress folder
#rm -R wordpress
#create wp config
#create uploads folder and set permissions
set echo off
mkdir wp-content/uploads
chmod 777 wp-content/uploads
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
set echo off
set echo on
echo "============================================"
echo "				Tehtud!						  "
echo "============================================"
ls -R /etc > /tmp/x
rm -f /tmp/x
# your logic ends here
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
