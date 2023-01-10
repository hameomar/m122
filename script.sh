#!/bin/bash
# um einen Ordner für die Logs zu erstellen.
mkdir ~/OwnCloud-Installation-Logs/
#Datenschutz Meldung und mit einer Case-Anweisung, um eine Option auszuwählen. Wenn eine Option ausgewählt wurde, wird ein Code zurückgegeben, um die nächste Sache zu tun oder den Prozess abzubrechen.
#Ungültige Abgaben werden abgefnagen. Der User muss immer nur Zahlen eingeben. 1 für Ja und 2 für Nein
#Quelle https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script 
#Kommentar vom Myrddin Emrys. answered Oct 22, 2008 at 17:08
#mit dem break Befehl beende ich die Case Anweisung und springe zum nächsten Zielencode.
echo ' Privacy: This bash script installs OwnCloud Server and the necessary software on your server, as well as MariaDB and Apache2, PHP7. The Apache web server configuration will be adjusted. Remember, if you have important data on the server, you can make a backup first. otherwise I will create a backup for your configuration and you can restore it anytime. Do you accept this? '
    select yn in "Yes" "No" ;do
       case $yn in
            Yes) break;;
            No) exit;;
	     *) echo "I cant understand, it's a simple question...enter 1 for Yes or 2 for No " >&2
       esac
        done
#Mit diesem Funktion zeige ich einen Text. Man kann es mit Firma Logo ersetzten.Quelle ist mir nicht bakannt. Vom Google bekommen.
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
#Text Print mit Warte Zeit von 2 Sekunden. Mit dem Befehl Reset leere ich das Terminal Fenster.
showMe
echo "Thanks for using this script....."
sleep 2s
reset

echo "starting....";

# um eine Warte Meldung anzuzeigen. Der Cursor dreht 10 Mal und die Geschwindigkeit ist 0,1 Sekunde. Quelle: https://gist.github.com/loa/e5824fc2b14979b5ce38
#Eine Bash for-Schleife ist eine Anweisung, mit der Code wiederholt ausgeführt werden kann
#wir können die Zahlen oder Zeichenfolge in der Bash mit dem Befehl seq iterieren. der Befehl seq gibt eine Folgen aus
#mit echo -ne '\b' , stellen man ein, dass nur Curosr Status angezeigt werden soll und nicht so: -,\\,|,/. 
#echo -n = no new line. Aber "Der Umriss am Ende wird weggelassen" : https://www.tutorialkart.com/bash-shell-scripting/bash-echo/
# echo -e ="Aktivierung der Interpretation von Backslash-Escaped-Zeichen"
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

# Single loop, kann man ohne Zahl eingeben
rotateCursor

# mehrere loops
rotateCursor 10
#hier geht es darum, das System Version und Release zu prüfen. der Zweite Teil speichert das Output als Log. Keine Quelle, von mir selbst.
check_os () {
    echo "Checking your OS"
echo "check started"
lsb_release -a |& tee ~/OwnCloud-Installation-Logs/checkos-logs.txt
}
#hier startet die Installation für Ubuntu 22.04 Distro
installation_22.04 () {
    echo "Die Installation ist begonnen..."
#backup apache2 Folder, falls es vorhanden ist. Damit wir später es wiederherstellen können. Quelle: https://linuxconfig.org/bash-scripting-check-if-directory-exists
# mit der Option -d zeige ich nur den Ordner zum lesen. ls -d /etc/ gibt nur /etc als output
DIR="/etc/apache2/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "Apache exist, i will backup your config ${DIR}..."
  cp -r /etc/apache2 /etc/apache2.back
fi
#apt-get update  # To get the latest package lists
#test if apache2 installed. Wenn Apache nicht installiert ist, wird eine Meldung angeziegt und Apache WebServer wird installiert.
#Quelle: stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script
if ! which apache2 > /dev/null; then
   echo -e "you have not installed apache2 Server yet, i will install it for you.."
sudo apt install apache2 -y |& tee ~/OwnCloud-Installation-Logs/apache-logs.txt
fi
reset
echo " Apache Server installed successfully ";
# um eine Warte Meldung anzuzeigen. Der Cursor dreht 6 Mal und die Geschwindigkeit ist 0,1 Sekunde. Quelle: https://gist.github.com/loa/e5824fc2b14979b5ce38
#Eine Bash for-Schleife ist eine Anweisung, mit der Code wiederholt ausgeführt werden kann
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

#backup mysql Folder, falls es vorhanden ist. Quelle: https://linuxconfig.org/bash-scripting-check-if-directory-exists
DIR="/etc/mysql/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "mysql exist, i will backup your config ${DIR}..."
  cp -r /etc/mysql /etc/mysql.back
fi
#test if mariaDB installed, wenn nicht wird eine Meldung angezeigt und installiert. Quelle : stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script

if ! which mariadb-server > /dev/null; then
   echo -e "you dont have installed mariadb Server yet, i will install it for you.."
#MariaDB Mysql installieren und die Logs speichern
sudo apt install mariadb-server -y |& tee ~/OwnCloud-Installation-Logs/mariabdserver-logs.txt
#MariaDB Client installieren.
sudo apt install mysql-client-core-8.0 -y |& tee ~/OwnCloud-Installation-Logs/mariadb-client.txt
#Manchmal funktioniert der erste Befehl nicht und das Wort apt-get eingefügt werden muss.
sudo apt-get install mysql-server -y
#um alle Module von MariaDB zu installieren. Wir brauchen nicht alle
sudo apt install mariadb* -y |& tee ~/OwnCloud-Installation-Logs/mariadb-extensions.txt
fi
reset
echo " MARIADB installed successfully .... ";
# um eine Warte Meldung anzuzeigen. Der Cursor dreht 6 Mal und die Geschwindigkeit ist 0,1 Sekunde. Quelle: Quelle: https://gist.github.com/loa/e5824fc2b14979b5ce38
#Eine Bash for-Schleife ist eine Anweisung, mit der Code wiederholt ausgeführt werden kann
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
#backup php Ornder, falls es schon vorhanden ist. Falls nicht, macht der Script weiter. Quelle: https://linuxconfig.org/bash-scripting-check-if-directory-exists
DIR="/etc/php/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "php exist, i will backup your config ${DIR}..."
  cp -r /etc/php /etc/php.back
fi
#check if php is installe, if not = install it. Quelle: stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script

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
#Quelle: https://www.linuxcapable.com/how-to-install-php-7-4-on-ubuntu-22-04-lts/
add-apt-repository ppa:ondrej/php --yes &> /dev/null |& tee ~/OwnCloud-Installation-Logs/php-repo-logs.txt
#mit dieser Befehl wird PHP 7.4 und die Module fürs Betreiben von Apache2 Server installiert. Die Logs werde immer bei wichtigen Befehlen gespeichert.
apt install php7.4 libapache2-mod-php7.4 php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} -y |& tee ~/OwnCloud-Installation-Logs/php-installation-logs.txt
#wir brauchen Curl und gnupg Tools für das Herunterladen vom Packages.
apt install curl gnupg2 -y |& tee ~/OwnCloud-Installation-Logs/curl-logs.txt
fi
reset
echo " PHP7.4 installed successfully .... ";
# um eine Warte Meldung anzuzeigen. Der Cursor dreht 6 Mal und die Geschwindigkeit ist 0,1 Sekunde. Quelle: https://gist.github.com/loa/e5824fc2b14979b5ce38
#Eine Bash for-Schleife ist eine Anweisung, mit der Code wiederholt ausgeführt werden kann
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
#Quelle: https://www.linuxtuto.com/how-to-install-owncloud-on-ubuntu-22-04/
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
#Grüne Meldung anzeigen, dass es installiert wurde.
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

   echo "Die Installation für Debian ist begonnen..."
#backup apache2 Folder, falls es vorhanden ist. Damit wir später es wiederherstellen können. Quelle: https://linuxconfig.org/bash-scripting-check-if-directory-exists
DIR="/etc/apache2/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "Apache exist, i will backup your config ${DIR}..."
  cp -r /etc/apache2 /etc/apache2.back
fi
#apt-get update  # To get the latest package lists
#test if apache2 installed. Wenn Apache nicht installiert ist, wird eine Meldung angeziegt und Apache WebServer wird installiert.
#Quelle: stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script
if ! which apache2 > /dev/null; then
   echo -e "you have not installed apache2 Server yet, i will install it for you.."
sudo apt install apache2 -y |& tee ~/OwnCloud-Installation-Logs/apache-logs.txt
fi
reset
echo " Apache Server installed successfully ";
# um eine Warte Meldung anzuzeigen. Der Cursor dreht 6 Mal und die Geschwindigkeit ist 0,1 Sekunde. Quelle: https://gist.github.com/loa/e5824fc2b14979b5ce38
#Eine Bash for-Schleife ist eine Anweisung, mit der Code wiederholt ausgeführt werden kann
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

#backup mysql Folder, falls es vorhanden ist. Quelle: https://linuxconfig.org/bash-scripting-check-if-directory-exists
DIR="/etc/mysql/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "mysql exist, i will backup your config ${DIR}..."
  cp -r /etc/mysql /etc/mysql.back
fi
#test if mariaDB installed, wenn nicht wird eine Meldung angezeigt und installiert. Quelle : stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script

if ! which mariadb-server > /dev/null; then
   echo -e "you dont have installed mariadb Server yet, i will install it for you.."
#MariaDB Mysql installieren und die Logs speichern
sudo apt install mariadb-server -y |& tee ~/OwnCloud-Installation-Logs/mariabdserver-logs.txt
#MariaDB Client installieren.
sudo apt install mysql-client-core-8.0 -y |& tee ~/OwnCloud-Installation-Logs/mariadb-client.txt
#Manchmal funktioniert der erste Befehl nicht und das Wort apt-get eingefügt werden muss.
sudo apt-get install mysql-server -y
#um alle Module von MariaDB zu installieren. Wir brauchen nicht alle
sudo apt install mariadb* -y |& tee ~/OwnCloud-Installation-Logs/mariadb-extensions.txt
fi
reset
echo " MARIADB installed successfully .... ";
# um eine Warte Meldung anzuzeigen. Der Cursor dreht 6 Mal und die Geschwindigkeit ist 0,1 Sekunde. Quelle: Quelle: https://gist.github.com/loa/e5824fc2b14979b5ce38
#Eine Bash for-Schleife ist eine Anweisung, mit der Code wiederholt ausgeführt werden kann
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
#backup php Ornder, falls es schon vorhanden ist. Falls nicht, macht der Script weiter. Quelle: https://linuxconfig.org/bash-scripting-check-if-directory-exists
DIR="/etc/php/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "php exist, i will backup your config ${DIR}..."
  cp -r /etc/php /etc/php.back
fi
#check if php is installe, if not = install it. Quelle: stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script

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
#Quelle: https://www.linuxcapable.com/how-to-install-php-7-4-on-ubuntu-22-04-lts/
add-apt-repository ppa:ondrej/php --yes &> /dev/null |& tee ~/OwnCloud-Installation-Logs/php-repo-logs.txt
#mit dieser Befehl wird PHP 7.4 und die Module fürs Betreiben von Apache2 Server installiert. Die Logs werde immer bei wichtigen Befehlen gespeichert.
apt install php7.4 libapache2-mod-php7.4 php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} -y |& tee ~/OwnCloud-Installation-Logs/php-installation-logs.txt
#wir brauchen Curl und gnupg Tools für das Herunterladen vom Packages.
apt install curl gnupg2 -y |& tee ~/OwnCloud-Installation-Logs/curl-logs.txt
fi
reset
echo " PHP7.4 installed successfully .... ";
# um eine Warte Meldung anzuzeigen. Der Cursor dreht 6 Mal und die Geschwindigkeit ist 0,1 Sekunde. Quelle: https://gist.github.com/loa/e5824fc2b14979b5ce38
#Eine Bash for-Schleife ist eine Anweisung, mit der Code wiederholt ausgeführt werden kann
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
#Quelle: https://www.linuxtuto.com/how-to-install-owncloud-on-ubuntu-22-04/
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
#Grüne Meldung anzeigen, dass es installiert wurde.
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
#hier startet die Installation von einem Self Signed Zertifikate SSL. 
#Quelle: https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-16-04
installation_ssl () {
    echo "SSL installation started"
#backup ssl Ordner, damit wir es später wiederherstellen können.
DIR="/etc/sll/"
if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "ssl exist, i will backup your config ${DIR}..."
  cp -r /etc/ssl /etc/ssl.back
fi
#Mit OpenSll Befehl kann man unter Linux Systeme eine Zertifikate generieren und installieren. Der User muss seinen Frima Name und Informationen eingeben.
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache.key -out /etc/ssl/certs/apache.crt |& tee ~/OwnCloud-Installation-Logs/ssl-logs.txt
#Jetzt muss ich Apache Konfig Informeirt, dass die Website eine SSL Zertifikate hat. Daher wird Port 443 benutzt. Die Pfad von .Key und .Crt Zertifikate mussen richtig sein.
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
#Jetzt muss ich die SSL Konfiguration Mode aktivieren
sudo a2enmod ssl |& tee ~/OwnCloud-Installation-Logs/enable-ssl-mode-logs.txt
#Mit diesem Befehl werde ich die SSL für die Seite aktivieren
sudo a2ensite default-ssl.conf |& tee ~/OwnCloud-Installation-Logs/enable-ssl-site-logs.txt
#Danach muss ich Apache neustarten
sudo systemctl restart apache2 |& tee ~/OwnCloud-Installation-Logs/reload-apache-afterssl-logs.txt
}
#hier startet das Backup Prozess
recovery () {
    echo "recovery proccess is running"
#Zuerst mussen alle Dienste mit der Arbeit aufhören. Mysql und Apache, MariaDB. Für Php kann man nicht
sudo service apache2 stop ; sudo service mysql stop ; sudo service mariadb stop	|& tee ~/OwnCloud-Installation-Logs/diable-services-logs.txt
#Ich wiederherstelle Apache Konfig
rm -r /etc/apache2 ; cp -r /etc/apache2.back /etc/apache2 |& tee ~/OwnCloud-Installation-Logs/recovery-apache.txt
#Wiederherstellen vom Mysql Konfiguration
rm -r /etc/mysql ; cp -r /etc/mysql.back /etc/mysql |& tee ~/OwnCloud-Installation-Logs/recovery-mysql-logs.txt
#Wiederherstellen vom Php Konfig
rm -r /etc/php ; cp -r /etc/php.back /etc/php |& tee ~/OwnCloud-Installation-Logs/recovery-php-logs.txt
#Wiederherstellen vom SSL Konfiguration
rm -r /etc/ssl/ ; cp -r /etc/ssl.back /etc/ssl |& tee ~/OwnCloud-Installation-Logs/recovery-ssl-logs.txt
# Das Löschen vom OwnCloud Seite
rm -r /var/www/owncloud |& tee ~/OwnCloud-Installation-Logs/remove-owncloud-logs.txt
# Das Löschen von Curl und DownLoad Tools
sudo apt purge curl gnupg2 -y
#Mega Tools löschen
sudo apt purge megatools -y
#Am Schluss muss ich das Repo wiederherstellen und updaten
rm -r /etc/apt/ ; cp -r /etc/apt.back /etc/apt ; apt update -y |& tee ~/OwnCloud-Installation-Logs/recovery-apt-logs.txt

}
# Hier ist meine Haupt Schleif für das Anzeigen und Auswählen vom Optionen.Bash While True ist eine Bash-While-Schleife, bei der die Bedingung immer wahr ist und die Schleife unendlich oft ausgeführt wird. 
# Eine Case-Anweisung ist eine bedingte Kontrollstruktur, die eine Auswahl zwischen mehreren Gruppen von Programmanweisungen ermöglicht. 
#Quelle: https://stackoverflow.com/questions/47399306/case-statement-in-a-while-loop-shell-scripting der erste Kommentar
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
#Auch hier habe ich eine zweite Case-Anweisung zum Abbrechen und einen Schritt zurück zur Haupt-Case-Anweisung.
#Quelle: https://linuxize.com/post/bash-case-statement/
#bezüglich >&2 https://stackoverflow.com/questions/23489934/echo-2-some-text-what-does-it-mean-in-shell-scripting
    echo "Have you completed your task?"
    select opt in "break the installation" "Yes, go back to installation"; do
        case $REPLY in
            1) break 2 ;;
            2) break ;;
            *) echo "I cant understand, it's a simple question...enter 1 or 2 and so on" >&2
        esac
    done
done
