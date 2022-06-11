#!/bin/bash
P_IP="`wget http://ipinfo.io/ip -qO -`"
echo $P_IP
apt update && apt -y upgrade && apt -y install ufw
ufw allow OpenSSH && echo "y" | ufw enable
ufw allow 80
ufw allow 443
apt -y install apache2
apt -y install software-properties-common
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
add-apt-repository 'deb [arch=amd64] http://mariadb.mirror.globo.tech/repo/10.5/ubuntu focal main'
apt update && apt -y install mariadb-server mariadb-client

apt -y install php libapache2-mod-php php-mysql php-curl php-gd php-json php-mbstring php-imap php-iconv php-dev

apt update
apt -y install build-essential curl nano wget lftp unzip bzip2 arj nomarch lzop htop openssl gcc git binutils libmcrypt4 libpcre3-dev make python3 python3-pip supervisor unattended-upgrades whois zsh imagemagick uuid-runtime net-tools

apt install certbot python3-certbot-apache -y
mkdir /var/www/$P_IP
chown -R $USER:$USER /var/www/$P_IP

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

a2enmod rewrite
a2ensite $P_IP
a2dissite 000-default
systemctl reload apache2
systemctl restart apache2
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
rm /etc/apache2/mods-enabled/dir.conf
cat /etc/apache2/mods-enabled/dir.conf <<EOL
<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOL


mysql_secure_installation <<EOF
y
Newcloudpass22##
y
y
y
y
EOF
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
echo "alias wp='~/wp-cli.phar'" >> .bashrc
apt update && apt autoremove -y
apt clean

wget https://raw.githubusercontent.com/dedicatedcloud/lp.sh/main/new.sh 

chmod +x new.sh
mv new.sh /usr/local/bin/new

echo "alias new='~/usr/local/bin/new'" >> .bashrc
