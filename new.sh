#/bin/sh
echo -e "Please, provide us with your domain name: "
  read domain_name
  echo -e "Please, provide us with your email: "
  read domain_email
  echo -e "Please, provide us with a user name: "
  read user_name
  echo -e "Please, provide us with a password: "
  read password
  echo -e "Please, provide your site title: "
  read site_title
db_name="wp`date +%s`"
db_user=$db_name
db_password=`date |md5sum |cut -c '1-12'`
sleep 1
mysqlrootpass=`date |md5sum |cut -c '1-12'`
sleep 1

mysql_secure_installation <<EOF
y
$mysqlrootpass
y
y
y
y
EOF

cd ~/
mkdir -p $domain_name/logs $domain_name/public
chmod -R 755 $domain_name

cat >/etc/apache2/sites-available/$domain_name.conf <<EOL
<VirtualHost *:80>
    ServerName $domain_name
    ServerAlias www.$domain_name
    ServerAdmin $domain_email
    DocumentRoot ~/$domain_name/public
    ErrorLog ~/$domain_name/error.log
    CustomLog ~/$domain_name/access.log combined
    <Directory ~/$domain_name/public>
	   AllowOverride All
    </Directory>
</VirtualHost>
EOL
sudo a2enmod rewrite
sudo a2ensite $domain_name
sudo systemctl reload apache2
sudo systemctl restart apache2

mysql -u root -p <<EOL
$mysqlrootpass
CREATE DATABASE $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
CREATE USER '$db_name'@'localhost' IDENTIFIED BY '$db_password';




cd ~/$domain_name/public

wp core download
wp core config --dbname=$db_name --dbuser=$db_name --dbpass=$db_password
wp db create
wp core install --url=https://$domain_name --title=$site_title --admin_user=$user_name --admin_email=$domain_email --admin_password=$password
