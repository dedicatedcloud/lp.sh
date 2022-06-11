#!/bin/bash
echo -e "Please, provide us with a user name: "
  read user_name
  echo -e "Please, provide us with a password: "
  read password
P_IP="`wget http://ipinfo.io/ip -qO -`"
echo $P_IP
sudo apt update && sudo apt -y upgrade && sudo apt -y install ufw
sudo ufw allow OpenSSH && echo "y" |sudo ufw enable
sudo ufw allow 80
sudo ufw allow 443
sudo apt -y install apache2
sudo apt -y install software-properties-common
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
add-apt-repository 'deb [arch=amd64] http://mariadb.mirror.globo.tech/repo/10.5/ubuntu focal main'
sudo apt update && apt -y install mariadb-server mariadb-client

sudo apt -y install php libapache2-mod-php php-mysql php-curl php-gd php-json php-mbstring php-imap php-iconv php-dev

sudo apt update
sudo apt -y install build-essential curl nano wget lftp unzip bzip2 arj nomarch lzop htop openssl gcc git binutils libmcrypt4 libpcre3-dev make python3 python3-pip supervisor unattended-upgrades whois zsh imagemagick uuid-runtime net-tools

sudo apt install certbot python3-certbot-apache -y
sudo mkdir /var/www/$P_IP
sudo chown -R $USER:$USER /var/www/$P_IP

cat >/etc/apache2/sites-available/$P_IP.conf <<EOL
<VirtualHost *:80>
    ServerName $P_IP
    ServerAlias www.$P_IP
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/$P_IP
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/$P_IP/>
           AllowOverride All
    </Directory>
</VirtualHost>
EOL

sudo a2enmod rewrite
sudo a2ensite $P_IP
sudo a2dissite 000-default
sudo systemctl reload apache2
sudo systemctl restart apache2
cat >/var/www/$P_IP/index.html <<EOL

<html>
  <head>
    <title>$P_IP website</title>
  </head>
  <body>
    <h1>Hello World!</h1>

    <p>This is the landing page of <strong>$P_IP</strong>.</p>
  </body>
</html>
EOL
sudo rm /etc/apache2/mods-enabled/dir.conf
cat /etc/apache2/mods-enabled/dir.conf <<EOL
<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOL



sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
sudo echo "alias wp='/usr/local/bin/wp'" >> .bashrc
sudo apt update && apt autoremove -y
sudo apt clean

