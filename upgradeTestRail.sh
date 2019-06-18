#!/usr/bin/env bash

timeStamp=$(date "+%Y.%m.%d-%H.%M.%S")
dbFolder=_mysql
optFolder=_opt

echo
echo "###########################################################################################"
echo " TestRail quick upgrade"
echo " This script will help you to upgrade TestRail quickly."
echo " It currently only works with the 'standard docker-compose.yml' file , which uses Apache."
echo " !! Important: If you're running nginx, you need to do the update manually for now."
echo "###########################################################################################"
echo

read -p "Press 'Enter' to continue (or Ctrl+C to abort)"
echo

echo "Upgrading TestRail"
echo " -- assuming the DB is in _mysql and the reports/attachments/... files in _opt"
echo

echo "These TestRail versions are available"
wget -q https://registry.hub.docker.com/v1/repositories/cbreit/testrail-apache/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'
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


echo "Creating backup file"
sudo tar czf "testrail-backup-${timeStamp}".tar.gz ./_opt ./_mysql ./_config/config.php


echo "Getting new TestRail version and then restarting TestRail"

docker-compose pull
docker-compose down -v
docker-compose up -d

echo
echo "We're done :-)"