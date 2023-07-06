apt -y update &&  apt -y install wget dpkg

apt install lsb-release apt-transport-https ca-certificates software-properties-common -y

wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg 

sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

apt -y update && apt -y upgrade

apt -y  install apache2 php8.2 libapache2-mod-php8.2 php8.2-common php8.2-mysql php8.2-xml php8.2-xmlrpc php8.2-curl php8.2-gd php8.2-imagick php8.2-cli php8.2-dev php8.2-imap php8.2-mbstring php8.2-opcache php8.2-soap php8.2-zip php8.2-intl

apt -y install mariadb-server-10.5

echo "mariadb-server-10.5 mysql-server/root_password password root"        | debconf-set-selections
echo "mariadb-server-10.5 mysql-server/root_password_again password root"  | debconf-set-selections

wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb

dpkg -i zabbix-release_6.4-1+debian11_all.deb

apt -y update 

apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent


echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8  " | debconf-set-selections
echo "locales locales/default_environment_locale select en_US.UTF-8"           | debconf-set-selections
sed -i 's/^# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
dpkg-reconfigure --frontend=noninteractive locales
update-locale

zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -uzabbix -p zabbix

mysql -u root -p=root << EOL
CREATE USER 'zabbixuser'@'localhost' IDENTIFIED BY 'teclado';
CREATE DATABASE zabbixdb character set utf8mb4 collate utf8mb4_bin;
GRANT ALL PRIVILEGES ON zabbixdb.* TO zabbixuser@localhost IDENTIFIED BY 'teclado';
FLUSH PRIVILEGES;
QUIT

EOL


sed -i "105s/.*/DBName=zabbixdb /" /etc/zabbix/zabbix_server.conf
sed -i "121s/.*/DBUser=zabbixuser /"  /etc/zabbix/zabbix_server.conf
sed -i "129s/.*/DBPassword=teclado /"  /etc/zabbix/zabbix_server.conf

sed -i "105s/.*/max_execution_time = 300 /"  /etc/php/8.2/apache2/php.ini
sed -i "105s/.*/max_input_time = 300 /"  /etc/php/8.2/apache2/php.ini
sed -i "105s/.*/post_max_size = 16M /"  /etc/php/8.2/apache2/php.ini 



systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
systemctl status zabbix-server zabbix-agent php-* apache2



