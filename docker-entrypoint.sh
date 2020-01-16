#!/bin/sh

# FILE=/var/www/mediawiki/LocalSettings.php
# if [ -f "$FILE" ]; then
#     echo "LocalSettings Found"
# else   
while [ `/bin/nc $MEDIAWIKI_DB_HOST 3306 < /dev/null > /dev/null; echo $?` != 0 ]; do
	echo "Waiting for database to come up at $MEDIAWIKI_DB_HOST:3306..."
	sleep 1
done

echo "Executing CLI Script...." 
php maintenance/install.php \
                --confpath /var/www/mediawiki \
                --dbname "$MYSQL_DATABASE" \
                --dbserver "$MEDIAWIKI_DB_HOST" \
                --dbuser "root" \
                --dbpass "$MYSQL_ROOT_PASSWORD" \
                --installdbuser "root" \
                --installdbpass "$MYSQL_ROOT_PASSWORD" \
                --server "$MEDIAWIKI_SITE_SERVER" \
                --pass "$MEDIAWIKI_ADMIN_PASS" \
                --scriptpath "" \
                "$MEDIAWIKI_SITE_NAME" \
                "$MEDIAWIKI_ADMIN_USER" 
# fi1

# chown -R www-data:www-data /var/www/mediawiki
exec "$@"
