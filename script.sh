#!/bin/bash

showMe(){

echo " ___________ ______   _____ _____ _____ _____ _____ _     ";
echo "|_   _| ___ |___  /  |_   _/  __ |_   _/ __  |  _  | |    ";
echo "  | | | |_/ /  / ______| | | /  \/ | | \`' / /| |/'| |__  ";
echo "  | | | ___ \ / |______| | | |     | |   / / |  /| | '_ \ ";
echo "  | | | |_/ ./ /___   _| |_| \__/\ | | ./ /__\ |_/ | |_) |";
echo "  \_/ \____/\_____/   \___/ \____/ \_/ \_____/\___/|_.__/ ";
echo "                                                          ";
echo "                                                          ";

}

showMe
echo " TBZ OMAR"
echo "Thanks for using this script....."
sleep 2s
reset
sleep 1s
echo "TBZ OMAR"
sleep 2s
reset

echo "starting....";


rotateCursor() {
s="-,\\,|,/"
    for i in `seq 1 $1`; do
        for i in ${s//,/ }; do
            echo -n $i
            sleep 0.1
            echo -ne '\b'
        done
    done
}

# Single loop
rotateCursor

# 2 loops
rotateCursor 10

check_os () {
    echo "Checking your OS"
echo ===================
lsb_release -a
}

installation_22.04 () {
    echo "Die Installation ist begonnen..."
#LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL

apt-get update  # To get the latest package lists
apt install apache2 mariadb-server -y
apt-cache search php7.4
add-apt-repository ppa:ondrej/php --yes &> /dev/null
apt install php7.4 libapache2-mod-php7.4 php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} -y
apt install curl gnupg2 -y
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10.9.1/Ubuntu_22.04/ /' > /etc/apt/sources.list.d/isv:ownCloud:server:10.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:10/Ubuntu_20.04/Release.key | gpg --dearmor > /etc/apt/trusted.gpg.d/isv_ownCloud_server_10.gpg
apt update
apt install owncloud-complete-files -y
mkdir /var/www/owncloud
cat > /etc/apache2/sites-available/owncloud.conf << 'EOL'
Alias / "/var/www/owncloud/"
<Directory /var/www/owncloud/>
  Options +FollowSymlinks
  AllowOverride All
 <IfModule mod_dav.c>
  Dav off
 </IfModule>
 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
EOL

a2ensite owncloud.conf
a2dissite 000-default.conf
a2enmod rewrite mime unique_id
apachectl -t
systemctl restart apache2
mysql --password=1234-XYZ --user=root --host=localhost << eof
create database ownclouddb;
grant all privileges on ownclouddb.* to root@localhost identified by "1234-XYZ";
flush privileges;
exit;
eof
cd /var/www/owncloud
sudo -u www-data php occ maintenance:install \
   --database "mysql" \
   --database-name "ownclouddb" \
   --database-user "root"\
   --database-pass "1234-XYZ" \
   --admin-user "root" \
   --admin-pass "1234-XYZ"
#LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
reset
BIGreen='\033[1;92m'
printf  "${BIGreen} * OWNCLOUD WURDE ERFOLGREICH INSTALLIERT "
printf  "${BIGreen} * Um sich anzumelden, besuchen Sie http://loaclhost"
printf  "${BIGreen} * Das PW:1234-XYZ"
printf  "${BIGreen} * und der User : root "
printf  "${BIGreen} * Für Sicherheitsgrunden ändern Sie bitte Ihr PW und deaktivieren Sie den Benutzer root "

}

installation_other () {
    echo "install"
apt update
}

while true; do
    options=("Checking your OS" "install for ubuntu 22.04 and above" "install for other debain based OS")

    echo "Choose an option:"
    select opt in "${options[@]}"; do
        case $REPLY in
            1) check_os; break ;;
            2) installation_22.04; break ;;
            3) installation_other; break ;;
            *) echo "i cant understand your entrie, choose 1 or 2" >&2
        esac
    done

    echo "Doing other things..."

    echo "Have you checked your OS Rlease?"
    select opt in "No, break the installation" "Yes, go back to installation"; do
        case $REPLY in
            1) break 2 ;;
            2) break ;;
            *) echo "Look, it's a simple question...enter 1 or 2" >&2
        esac
    done
done
