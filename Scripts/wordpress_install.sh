#!/bin/bash

# Вместо su писать su -
# в противном случаем многие команды не сможет найти например: a2enmod, a2ensite

# example:
# sh script.sh -phpVersion 5.6 -siteName wp.com -dbname wp -dbuser wp_user -dbpass wp_pass
#
# default: 
# sh script.sh -phpVersion 7.4 -siteName site.com -dbname db -dbuser username -dbpass password

siteName=site.com
phpVersion=7.4
dbName=db
dbUser=username
dbPass=password

while [ -n "$1" ]
do
	case "$1" in
		-site)
			siteName=$2
			shift
			;;

		-php)
			phpVersion=$2
			shift 
			;;
			
		-dbname)
			dbName=$2
			shift 
			;;

		-dbuser)
			dbUser=$2
			shift 
			;;

		-dbpass)
			dbPass=$2
			shift 
			;;

		--)
			shift
			break
			;;

		*) echo "$1 is not an option";;
	esac
	
	shift
done

sh ./apache.sh
sh ./php.sh -version $phpVersion
sh ./wordpress.sh -site $siteName
sh ./regsite.sh -site $siteName
# don't work - sql query
/bin/bash ./mysql.sh -dbname $dbName -dbuser $dbUser -dbpass $dbPass


echo '------------------ APACHE ------------------'

echo Install apache and utils
apt install apache2 apache2-utils

echo Enable and Start apache
systemctl enable apache2
systemctl start apache2


# example:
# sh mysql.sh -dbname wp -dbuser wp_user -dbpass wp_pass
#
# default: 
# sh mysql.sh -dbname db -dbuser username -dbpass password

dbName=db
dbUser=username
dbPass=password

while [ -n "$1" ]
do
	case "$1" in
		-dbname)
			dbName=$2
			shift 
			;;

		-dbuser)
			dbUser=$2
			shift 
			;;

		-dbpass)
			dbPass=$2
			shift 
			;;

		--)
			shift
			break
			;;

		*) echo "$1 is not an option";;
	esac
	
	shift
done

echo '------------------ MYSQL ------------------'

function package_exists() {
    return apt-cache pkgnames | grep -x "$1" | wc -l
}

if [ package_exists mysql-server == 1 ]
then
    apt install -y mysql-client mysql-server
else
	apt install -y mariadb-client mariadb-server
fi

# mysql_secure_installation


mysql -u root -p << eof
CREATE DATABASE $dbName;
CREATE USER '$dbUser'@'localhost' IDENTIFIED BY '$dbPass';
GRANT ALL PRIVILEGES ON $dbName.* TO '$dbUser'@'localhost';
FLUSH PRIVILEGES;
eof


# example:
# sh php.sh -version 6.5
#
# default: 
# sh php.sh -version 7.4

version=7.4

while [ -n "$1" ]
do
	case "$1" in
		-version)
			version=$2
			shift 
			;;

		--)
			shift
			break
			;;

		*) echo "$1 is not an option";;
	esac
	
	shift
done

echo '------------------ PHP ------------------'

echo Install php and utils
apt install -y "php${version}" \
			"php${version}-mysql" \
			"libapache2-mod-php${version}" \
			"php${version}-cli" \
			"php${version}-cgi" \
			"php${version}-gd"


# Вместо su писать su -
# в противном случаем многие команды не сможет найти например: a2enmod, a2ensite

# example:
# sh regsite.sh -site wp.com
#
# default: 
# sh regsite.sh -site site.com

siteName=site.com

while [ -n "$1" ]
do
        case "$1" in
                -site)
                        siteName=$2
                        shift
                        ;;

                --)
                        shift
                        break
                        ;;

                *) echo "$1 is not an option";;
        esac

        shift
done


echo '------------------ REGISTER SITE ------------------'

ext="conf"
confPath="/etc/apache2/sites-available"
defaultConfPath="${confPath}/000-default.${ext}"
siteConfPath="${confPath}/${siteName}.${ext}"
siteFolder="/var/www/${siteName}"


echo Preparing site config
cp $defaultConfPath $siteConfPath
sed -i "s|#ServerName www.example.com|ServerName $siteName|" $siteConfPath
sed -i "s|DocumentRoot \/var\/www\/html|DocumentRoot $siteFolder|" $siteConfPath
sed -i "s|error.log|$siteName.error.log|" $siteConfPath
sed -i "s|access.log|$siteName.access.log|" $siteConfPath


echo Enable site
cd $confPath
a2ensite "${siteName}.${ext}"
systemctl reload apache2

echo Change apache mod and reboot
a2enmod rewrite
systemctl restart apache2


# example:
# sh wordpress.sh -site wp.com -owner username
#
# default: 
# sh wordpress.sh -site site.com -owner www-data

siteName=site.com
owner='www-data'

while [ -n "$1" ]
do
	case "$1" in
		-site)
			siteName=$2
			shift
			;;

		-owner)
			owner=$2
			shift
			;;

		--)
			shift
			break
			;;

		*) echo "$1 is not an option";;
	esac
	
	shift
done


echo '------------------ WORDPRESS ------------------'

ext="conf"
confPath="/etc/apache/sites-available"
defaultConfPath="${confPath}/000-default.${ext}"
siteConfPath="${confPath}/${siteName}.${ext}"
siteFolder="/var/www/${siteName}"

echo Load wordpress
wget -c http://wordpress.org/latest.tar.gz 
tar -xzf latest.tar.gz
rm -rf ./latest.tar.gz
mv ./wordpress $siteFolder
chown $owner:$owner -R $siteFolder
chmod -R 700 $siteFolder
