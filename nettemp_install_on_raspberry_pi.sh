#/bin/bash 
# nettemp rpi installer
# nettemp.pl
# 
# 2012.08.19

echo "update distro"
apt-get update
apt-get -y upgrade

echo "install git-core"
apt-get -y install git-core

echo "install packages"
apt-get -y install lighttpd php5-cgi php5-sqlite rrdtool sqlite3 msmtp digitemp


echo "enable module: fastcgi-php"
lighty-enable-mod fastcgi-php

echo "changing lighthttpd conf"
sed -i -e 's/#       "mod_rewrite",/       "mod_rewrite",/g'  /etc/lighttpd/lighttpd.conf
sed -i -e 's/server.document-root        = \"\/var\/www\"/server.document-root        = \"\/var\/www\/nettemp\"/g'  /etc/lighttpd/lighttpd.conf	
echo "url.rewrite-once = ( \"^/([A-Za-z0-9-_-]+)\$\" => \"/index.php?id=\$1\" )" >> /etc/lighttpd/lighttpd.conf


echo "downloading nettemp source"
cd /var/www
git clone https://github.com/sosprz/nettemp

echo "permisions"
chown -R root.www-data /var/www/nettemp
chmod -R 775 /var/www/nettemp
gpasswd -a www-data dialout
chmod +s /var/www/nettemp/modules/logoterma/relay


echo "add cron"
echo "*/10 * * * * /var/www/nettemp/modules/sensors/read" >> /var/spool/cron/crontabs/root
echo "1 * * * * /var/www/nettemp/modules/mail/mail" >> /var/spool/cron/crontabs/root
echo "*/2 * * * * /var/www/nettemp/modules/view/view_gen" >> /var/spool/cron/crontabs/root
echo "# 1 * * * * /var/www/nettemp/modules/sms/sms" >> /var/spool/cron/crontabs/root
echo "*/5 * * * * /var/www/nettemp/modules/logoterma/logoterma" >> /var/spool/cron/crontabs/root

update-rc.d ntp enable
service ntp start

update-rc.d lighttpd enable
service lighttpd stop
service lighttpd start

update-rc.d cron defaults
service cron start

echo "restart RPI to make sure everything is ok"
