#!/usr/bin/env bash

if [ ! -d /var/www/pimcore ]; then
    echo "Couldn't find any files for pimcore, downloading new files"
    if [ "$SAMPLE_DATA" = true ]; then
        echo "Downloading Pimcore with sample data"
        wget --progress=dot:mega https://www.pimcore.org/download/pimcore-data.zip -O pimcore-install.zip
        echo "######################################"
        echo "##### Extracting pimcore archive #####"
        echo "######################################"
        echo "THIS CAN TAKE QUITE SOME TIME, the sample data contains a lot of files!"
        sleep 10
    elif [ "$SAMPLE_DATA" = false ]; then
        echo "Downloading Pimcore professional (without sample data)"
        wget --progress=dot:mega https://pimcore.com/download-5/pimcore-latest.zip -O pimcore-install.zip
        echo "extracting pimcore archive, this will take some time"
    else
        echo "Unknown value in .env of variable PIMCORE_SAMPLE_DATA : " + $SAMPLE_DATA
        echo "Please select either 'true' (install with sample data), or 'false' (professional without sample data)"
        echo "Aborting"
        exit
    fi

    unzip pimcore-install.zip -d /var/www/
    echo "Removing archive"
    rm pimcore-install.zip
    echo "Copying cache config"
    cp /tmp/cache.php /var/www/website/var/config/cache.php

    if [ "$SAMPLE_DATA" = true ]; then
        echo "Copying system config"
        cp /tmp/system.php /var/www/website/var/config/system.php
        echo "Changing database variables in system.php"
        echo "username: " +  ${MYSQL_USER}
        sed -i "/\"username\" => \"MYSQL_USER\"/c               \"username\" => \"${MYSQL_USER}\"," /var/www/website/var/config/system.php
        echo "password: " +  ${MYSQL_PASSWORD}
        sed -i "/\"password\" => \"MYSQL_PASSWORD\"/c               \"password\" => \"${MYSQL_PASSWORD}\"," /var/www/website/var/config/system.php
        echo "dbname: " +  ${MYSQL_DATABASE}
        sed -i "/\"dbname\" => \"MYSQL_DATABASE\"/c             \"dbname\" => \"${MYSQL_DATABASE}\"," /var/www/website/var/config/system.php
        echo "Setting up database for sample data"
        apt-get update -q
        apt-get install -y --no-install-recommends mysql-client
        mysql --host db -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE < /var/www/pimcore/modules/install/mysql/install.sql
        mysql --host db -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE < /var/www/website/dump/data.sql
        mysql --host db -u $MYSQL_USER --password=$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "UPDATE users SET id = '0' WHERE name = 'system'"
        echo "Resetting admin credentials"
        php /var/www/pimcore/cli/console.php reset-password -u admin -p demo
        apt-get purge mysql-client
        apt autoremove
        echo "############################################################################"
        echo "pimcore database for sample data installed, admin user: admin password: demo"
        echo "############################################################################"
        sleep 10
    fi

    echo "Cleaning tmp"
    rm /tmp/*
    echo "Changing ownership of /var/www"
    chown -R www-data /var/www/
    echo "New pimcore files installed"

else
    echo "Found existing pimcore files, skipping download"
fi

echo "Starting php-fpm7.0 in foreground"
php-fpm7.0 -F

