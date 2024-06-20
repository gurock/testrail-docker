#!/usr/bin/env bash

timeStamp=$(date "+%Y.%m.%d-%H.%M.%S")
dbFolder=_mysql
optFolder=_opt
confFolder=_config

backupDir=backup
mkdir -p  $backupDir

echo
echo "###########################################################################################"
echo " TestRail quick upgrade"
echo " This script will help you to upgrade TestRail."
echo " It currently only works with the 'standard docker-compose.yml' file , which uses Apache."
echo " !! Important: If you're running nginx, you need to do the update manually for now."
echo
echo " Please be aware that you will need 'sudo' installed to run this script."
echo "###################################################################################"
echo

read -p "Press 'Enter' to continue (or Ctrl+C to abort)"
echo

echo "Upgrading TestRail"
echo " -- assuming the DB is in _mysql and the reports/attachments/... files in _opt"
echo

echo "These TestRail versions are available"
wget -q -O - "https://hub.docker.com/v2/repositories/testrail/apache/tags" | grep -o '"name": *"[^"]*' | grep -o '[^"]*$'
echo

read -r -p "Press 'l' to continue with 'latest' or type in the version you want to use: " version
echo

if [ "$version" = 'l' ]; then
    sed -i "s/TESTRAIL_VERSION=.*/TESTRAIL_VERSION=latest/g" .env
else
    if grep -Fxq "TESTRAIL_VERSION" .env
    then
        sed -i "s/TESTRAIL_VERSION=.*/TESTRAIL_VERSION=${version}/g" .env
    else
        echo "TESTRAIL_VERSION=${version}" >> .env
    fi
fi

echo
echo "###########################################################################################"
echo " If you're upgrading from a docker applicance, simply continue. Otherwise, do these steps:"
echo "   * Ensure that the 'config.php' file is in the '_config folder'."
echo "   * Copy the content of /var/lib/mysql to '_mysql'"
echo "     (if you're using a dedicated mysql server for TestRail -- otherwise do a manual upgrade)"
echo "   * Copy the content of /var/lib/cassandra to '_cassandra'"
echo "     (if you're using a dedicated mysql server for TestRail -- otherwise do a manual upgrade)"
echo "   * Copy/Move your attachment, reports, logs, and audit folders into '_opt'."
echo
echo " When you're done with these steps, simply continue."
echo "###################################################################################"
echo


read -p "Press 'Enter' to continue (or Ctrl+C to abort)"
echo


echo "Creating backup file"
sudo tar czf "${backupDir}/testrail-backup-${timeStamp}".tar.gz $optFolder $dbFolder $confFolder


echo "Getting new TestRail version and then restarting TestRail"

docker-compose pull
docker-compose down -v
docker-compose up -d

echo
echo "We're done :-)"