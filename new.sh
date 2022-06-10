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
  
sudo  mkdir /var/www/$domain_name/
sudo chown www-data: /var/www/$domain_name -R

cat >/etc/apache2/sites-available/$domain_name.conf <<EOL
<VirtualHost *:80>
    ServerName $domain_name
    ServerAlias www.$domain_name
    ServerAdmin $domain_email
    DocumentRoot /var/www/$domain_name
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    <Directory /var/www/$domain_name/>
	   AllowOverride All
    </Directory>
</VirtualHost>
EOL
sudo a2enmod rewrite
sudo a2ensite $domain_name
sudo systemctl reload apache2
sudo systemctl restart apache2
cat >/var/www/$domain_name/index.html <<EOL

<html>
  <head>
    <title>$domain_name website</title>
  </head>
  <body>
    <h1>Hello World!</h1>

    <p>This is the landing page of <strong>$domain_name</strong>.</p>
  </body>
</html>
EOL

wp core download --path=/var/www/$domain_name --locale=en_US
wp config create --dbname=$db_name --dbuser=$db_name --dbpass=$db_password
wp db create
wp core install --url=$domain_name --title="$site_title" --admin_user=$user_name --admin_password=$user_password --admin_email=$domain_email