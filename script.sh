#!/bin/bash
# um einen Ordner für die Logs zu erstellen.
mkdir ~/OwnCloud-Installation-Logs/
echo ' Privacy: This bash script installs OwnCloud Server and the necessary software on your server, as well as MariaDB and Apache2, PHP7. The Apache web server configuration will be adjusted. Remember, if you have important data on the server, you can make a backup first. otherwise I will create a backup for your configuration and you can restore it anytime. Do you accept this? '
    select yn in "Yes" "No" ;do
       case $yn in
            Yes) break;;
            No) exit;;
	     *) echo "I cant understand, it's a simple question...enter 1 or 2 and so on" >&2
       esac
        done

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
echo "Thanks for using this script....."
sleep 2s
reset

echo "starting....";

# um eine Warte Meldung anzuzeigen. Der Cursor dreht 10 Mal und die Geschwindigkeit ist 0,1 Sekunde
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
#hier geht es darum, das System Version und Release zu prüfen. der Zweite Teil speichert das Output als Log
check_os () {
    echo "Checking your OS"
echo "check started"
lsb_release -a |& tee ~/OwnCloud-Installation-Logs/checkos-logs.txt
}
#hier startet die Installation für Ubuntu 22.04 Distro
installation_22.04 () {
    echo "Die Installation ist begonnen..."
#backup apache2 Folder, falls es vorhanden ist. Damit wir später es wiederherstellen können.
DIR="/etc/apache2/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "Apache exist, i will backup your config ${DIR}..."
  cp -r /etc/apache2 /etc/apache2.back
fi
#apt-get update  # To get the latest package lists
#test if apache2 installed. Wenn Apache nicht installiert ist, wird eine Meldung angeziegt und Apache WebServer wird installiert.

if ! which apache2 > /dev/null; then
   echo -e "you have not installed apache2 Server yet, i will install it for you.."
sudo apt install apache2 -y |& tee ~/OwnCloud-Installation-Logs/apache-logs.txt
fi
reset
echo " installed successfully ";
# um eine Warte Meldung anzuzeigen. Der Cursor dreht 6 Mal und die Geschwindigkeit ist 0,1 Sekunde
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

rotateCursor
rotateCursor 6

#backup mysql Folder, falls es vorhanden ist.
DIR="/etc/mysql/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "mysql exist, i will backup your config ${DIR}..."
  cp -r /etc/mysql /etc/mysql.back
fi
#test if mariaDB installed, wenn nicht wird eine Meldung angezeigt und installiert.

if ! which mariadb-server > /dev/null; then
   echo -e "you dont have installed mariadb Server yet, i will install it for you.."
sudo apt install mariadb-server -y |& tee ~/OwnCloud-Installation-Logs/mariabdserver-logs.txt
sudo apt install mysql-client-core-8.0 -y |& tee ~/OwnCloud-Installation-Logs/mariadb-client.txt
sudo apt-get install mysql-server -y
sudo apt install mariadb* -y |& tee ~/OwnCloud-Installation-Logs/mariadb-extensions.txt
fi
reset
echo " MARIADB installed successfully .... ";
# um eine Warte Meldung anzuzeigen. Der Cursor dreht 6 Mal und die Geschwindigkeit ist 0,1 Sekunde
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

rotateCursor
rotateCursor 6

#Das Ondřej Surý PPA (Personal Package Archive) ist ein gängiger Weg, um bestimmte Versionen der PHP-Laufzeitumgebung unter Ubuntu mit dem APT-Paketmanager zu installieren. Dies ist eine inoffizielle Quelle und wird nicht von PHP.net gepflegt.
#backup php Ornder, falls es schon vorhanden ist. Falls nicht, macht der Script weiter
DIR="/etc/php/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "php exist, i will backup your config ${DIR}..."
  cp -r /etc/php /etc/php.back
fi
#check if php is installe, if not = install it

if ! which php > /dev/null; then
   echo -e "you dont have installed php yet, i will install it for you.."
#hier sucht das Script ob Php Repo im Cache vorhanden ist. Der Befehk kann gelöscht werden, weil es nutzlos ist.
apt-cache search php7.4
#backup apt folder. Damit wir die Datei Source.list später wiederherstellen, mussen wir am besten den Ordner backupen. 
DIR="/etc/apt/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "apt exist, i will backup your config ${DIR}..."
  cp -r /etc/apt /etc/apt.back
fi
#mit diesem Befehel werde ich einen benutzerdefinierten Repo eintragen, damit alte Versionen vom Php installiert werden können.
add-apt-repository ppa:ondrej/php --yes &> /dev/null |& tee ~/OwnCloud-Installation-Logs/php-repo-logs.txt
#mit dieser Befehl wird PHP 7.4 und die Module fürs Betreiben von Apache2 Server installiert. Die Logs werde immer bei wichtigen Befehlen gespeichert.
apt install php7.4 libapache2-mod-php7.4 php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} -y |& tee ~/OwnCloud-Installation-Logs/php-installation-logs.txt
#wir brauchen Curl und gnupg Tools für das Herunterladen vom Packages.
apt install curl gnupg2 -y |& tee ~/OwnCloud-Installation-Logs/curl-logs.txt
fi
reset
echo " PHP7.4 installed successfully .... ";
# um eine Warte Meldung anzuzeigen. Der Cursor dreht 6 Mal und die Geschwindigkeit ist 0,1 Sekunde

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

rotateCursor
rotateCursor 6

#Owncloud installation startet hier. Zuerst muss ich Mega Cloud Tools installieren, damit wir das Script herunterladen können.

sudo apt install megatools |& tee ~/OwnCloud-Installation-Logs/megatools.txt
#backup link: https://download.owncloud.com/server/stable/owncloud-complete-latest.tar.bz2
#mit diesem Befehle lade ich das OwnCloud Server Datei herunter.
megadl https://mega.nz/file/BDcCEb5A#l71_cTp345YMTT5aY4Hciz4CN4pCHloLeoJwIBbNFuA |& tee ~/OwnCloud-Installation-Logs/downlaodfrom-mega-logs.txt
#mit Tar Tool werde ich den Ornder entpacken.
tar -xjf owncloud.tar.bz2 |& tee ~/OwnCloud-Installation-Logs/tarexport-logs.txt
#der Ordner muss zum Web Server Ordner kopiert werden.
cp -r owncloud /var/www/ |& tee ~/OwnCloud-Installation-Logs/copy owncloadfolder-logs.txt
#jetzt muss ich Apache konfigurieren und informieren, dass es eine neue Website eingefügt wurde.
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
#mit diesem Befehl a2ensite aktiviere ich die neue Konfig Datei . Die Logs werden gespeichert.
a2ensite owncloud.conf |& tee ~/OwnCloud-Installation-Logs/owncloudserver-enable-logs.txt
#ich muss jetzt Apache informieren, dass der HauptWebsite localhost ist OwbCloud und nicht was im slash html ist. Ich meine das Default Index html Datei.
a2dissite 000-default.conf |& tee ~/OwnCloud-Installation-Logs/disable-default-config-apache2.txt
#damit PHP mit Apache korrekt funktioneiren kann und die Requests behandet werden könenn, mussen wir dies Modul aktivieren: unique_id 
a2enmod rewrite mime unique_id |& tee ~/OwnCloud-Installation-Logs/edit-rewrite-apache-config.txt
#apachectl ist das Controlr Panel vom Apache Server. Mit diesem Befehl macht ich der Server aufmerksam, dass es etwas gändert wurde.
apachectl -t |& tee ~/OwnCloud-Installation-Logs/apache2-test-logs.txt
#Mit diesem Befehl staret ich Apache Server neu
systemctl restart apache2 |& tee ~/OwnCloud-Installation-Logs/start-apache-logs.txt
#Jetzt müssen wir eine DB für Owncloud konfigurieren.
mysql --password=1234-XYZ --user=root --host=localhost << eof
create database ownclouddb;
grant all privileges on ownclouddb.* to root@localhost identified by "1234-XYZ";
flush privileges;
eof
#Ich muss einen Ordner für Data erstellen, sonst bekommt man manchmal Fehlermeldungen.
mkdir /var/www/owncloud/data
#Ich muss der Ownder und die Gruppe vom OwnCloud Ornder ändern. Normalerweise ist es user;user oder root;root
sudo chown -R www-data:www-data /var/www/owncloud/ |& tee ~/OwnCloud-Installation-Logs/apache-server-berechtigung.txt
#jetzt starte ich die Installation von diesem Server und gebe ich Informaitionen und Zugang Daten ein
cd /var/www/owncloud
sudo -u www-data php occ maintenance:install \
   --database "mysql" \
   --database-name "ownclouddb" \
   --database-user "root"\
   --database-pass "1234-XYZ" \
   --admin-user "root" \
   --admin-pass "1234-XYZ"
#Grüne Meldung anzeigen
reset
BIGreen='\033[1;92m'
printf  "${BIGreen} * OWNCLOUD WAS INSTALLED SUCCESSFULLY "
printf  "${BIGreen} * To sign in, visit http://localhost"
printf  "${BIGreen} * The PW:1234-XYZ"
printf  "${BIGreen} * and the User : root "
printf  "${BIGreen} * For security reasons please change your PW and disable the root user "
printf  "${BIGreen} * it is also recommended to install a SSL "
printf  "${BIGreen} * thanks for using this script "

}
#Das ist gemäss Anforderungsdefinition optional und ist für Debian gemeint.
installation_other () {
    echo "install"
apt update
}

installation_ssl () {
    echo "SSL installation started"
#backup ssl folder
DIR="/etc/sll/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "ssl exist, i will backup your config ${DIR}..."
  cp -r /etc/ssl /etc/ssl.back
fi	
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache.key -out /etc/ssl/certs/apache.crt |& tee ~/OwnCloud-Installation-Logs/ssl-logs.txt
cat > /etc/apache2/sites-available/default-ssl.conf << 'EOL'
<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		ServerAdmin webmaster@localhost
		ServerName 127.0.0.1
		DocumentRoot /var/www/html

		SSLEngine on
		SSLCertificateFile    /etc/ssl/certs/apache.crt
		SSLCertificateKeyFile /etc/ssl/private/apache.key
		
		<FilesMatch "\.(cgi|shtml|phtml|php)$">
				SSLOptions +StdEnvVars
		</FilesMatch>
		<Directory /usr/lib/cgi-bin>
				SSLOptions +StdEnvVars
		</Directory>

		
	</VirtualHost>
</IfModule>
EOL

sudo a2enmod ssl |& tee ~/OwnCloud-Installation-Logs/enable-ssl-mode-logs.txt
sudo a2ensite default-ssl.conf |& tee ~/OwnCloud-Installation-Logs/enable-ssl-site-logs.txt
sudo systemctl restart apache2 |& tee ~/OwnCloud-Installation-Logs/reload-apache-afterssl-logs.txt
}

recovery () {
    echo "recovery proccess is running"
sudo service apache2 stop ; sudo service mysql stop ; sudo service mariadb stop	
rm -r /etc/apache2 ; cp -r /etc/apache2.back /etc/apache2
rm -r /etc/mysql ; cp -r /etc/mysql.back /etc/mysql
rm -r /etc/php ; cp -r /etc/php.back /etc/php
rm -r /etc/ssl/ ; cp -r /etc/ssl.back /etc/ssl
rm -r /var/www/owncloud
sudo apt purge curl gnupg2 -y
sudo apt purge megatools -y
rm -r /etc/apt/ ; cp -r /etc/apt.back /etc/apt ; apt update -y

}

while true; do
    options=("Checking your OS" "install for ubuntu 22.04 and above" "install for other debain based OS" "install a self signed ssl" "recovery, undo system change" )

    echo "Choose an option:"
    select opt in "${options[@]}"; do
        case $REPLY in
            1) check_os; break ;;
            2) installation_22.04; break ;;
            3) installation_other; break ;;
            4) installation_ssl; break ;;
			5) recovery; break ;;
            *) echo "i cant understand your entrie, choose 1 or 2..etc" >&2
        esac
    done

    echo "Have you completed your task?"
    select opt in "break the installation" "Yes, go back to installation"; do
        case $REPLY in
            1) break 2 ;;
            2) break ;;
            *) echo "I cant understand, it's a simple question...enter 1 or 2 and so on" >&2
        esac
    done
done
