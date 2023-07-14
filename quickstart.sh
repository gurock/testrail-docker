#!/usr/bin/env bash

echo
echo "##################################################################################"
echo " TestRail quickstart"
echo
echo " This script will help you to quickly start a TestRail instance and will"
echo " populate a '.env' file with the necessary configuration values."
echo " For more advanced configuration please directly modify the .env file and utilize"
echo " docker-compose directly."

echo
echo " Please be aware that you will need 'sudo' installed to run this script."
echo "###################################################################################"
echo


read -p "Press 'Enter' to continue (or Ctrl+C to abort)"
echo

#variables definition
testrailDockerHubRepository="testrail/apache"
optFolder=_opt
backupDir=backup
dbFolder=_mysql
cassandraFolder=_cassandra
envFile=.env
configFile=_config/config.php
httpPort=8000

#####################################
# check if TestRail is already running

timeStamp=$(date "+%Y.%m.%d-%H.%M.%S")
dockerPSOutput=$(docker ps | grep testrail)

mkdir -p  $backupDir

if [ -n "${dockerPSOutput}" ];
then
    echo " ### Seems like a TestRail instance is already running"
    echo "   To shut it down run 'docker-compose down -v' in this folder and then call this script again."
    echo
    read -n1 -r -p "   Press 'c' to continue or any other key to abort..." key

    if [ "$key" != 'c' ]; then
        # shellcheck disable=SC2242
        exit -1
    fi
fi
echo

#####################################
# port
while($true)
do
    read -p "  Please enter the port number testrail use (default 8000) or press 'c' to continue: "  port

    if [[ "$port" = 'c' ]]; then
            echo "  --> Using port 8000 (default value)"
            echo
            break
    elif ! [[ "$port" =~ ^[0-9]+$ ]]; then
            echo "  --> Sorry integers only!"
            continue
    else
            echo "  --> Using port ${port}"
            httpPort=$port
            break
    fi
done

echo ""

#####################################
# testrail version

echo "These TestRail versions are available"
echo
tokenUri="https://auth.docker.io/token"
data=("service=registry.docker.io" "scope=repository:$testrailDockerHubRepository:pull")
token="$(curl --silent --get --data-urlencode ${data[0]} --data-urlencode ${data[1]} $tokenUri | jq --raw-output '.token')"
listUri="https://registry-1.docker.io/v2/$testrailDockerHubRepository/tags/list"
authz="Authorization: Bearer $token"
result="$(curl --silent --get -H "Accept: application/json" -H "Authorization: Bearer $token" $listUri | jq --raw-output '.')"
echo $result | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}' | sed 's/,/\n/g'
read -r -p "Press 'd' to use 'default' or type in the version you want to use: " version
echo

dockerComposeFile="docker-compose.yml";
if [ "$version" = 'd' ]; then
    testrailVersion="default"
else
    testrailVersion=$version
fi

#####################################
# database

echo
echo "An empty database named 'testrail' is automatically created together with the user 'testrail'."
echo "In succession, please enter a password for this user.
During the installation, use 'testrail' for the database name and the database-user and utilize the password you'll enter now."
echo
read -p "  Enter a password for the database user: "  pwd

echo
echo "The database also needs a secure root password (needed for debugging/emergency cases)"
echo
read -p "  Enter a database root password: "  root_pwd

echo
echo
echo "The database will be stored in the local folders '_mysql' and files created by TestRail will be placed in '_opt'."

if [ "$(ls -A $dbFolder)" ]; then
    echo "  ... The db-folder already contains files  -- moving it to '${backupDir}'"

    sudo mv $dbFolder $backupDir/"${dbFolder}_${timeStamp}"
    mkdir -p $dbFolder
fi

#####################################
# Cassandra

echo
echo
echo "The Cassandra database will be stored in the local '_cassandra' folder"

if [ "$(ls -A $cassandraFolder)" ]; then
    echo "  ... The Cassandra folder already contains files  -- moving it to '${backupDir}'"

    sudo mv $cassandraFolder $backupDir/"${cassandraFolder}_${timeStamp}"
    mkdir -p $cassandraFolder
fi

#####################################
# opt
if [ "$(ls -A $optFolder)" ]; then
    echo "  ... The opt-folder already contains files -- moving it to '${backupDir}'"

    sudo mv $optFolder $backupDir/"${optFolder}_${timeStamp}"
    mkdir -p $optFolder
fi

#####################################
# .env
if test -f "$envFile"; then
    echo "  ... A '.env' file already exists -- moving it to '${backupDir}'"

    mv .env $backupDir/.env_$timeStamp
fi

touch $envFile
echo "HTTP_PORT=${httpPort}"  >> .env
echo "DB_USER=testrail" >> .env
echo "DB_NAME=testrail" >> .env
echo "DB_PWD=${pwd}"    >> .env
echo "DB_ROOT_PWD=${root_pwd}" >> .env
echo "OPT_PATH=${optFolder}"  >> .env
echo "MYSQL_PATH=${dbFolder}"  >> .env
echo "TESTRAIL_VERSION=${testrailVersion}" >> .env

#####################################
# config.php

if test -f "$configFile"; then
    echo "A 'config.php' file already exists -- it will be saved and a new one will be created during the installation"

    sudo mv $configFile $backupDir/config.php_$timeStamp
fi

#####################################
# starting TestRail

echo
echo "TestRail will be started now with HTTP and will listen on port ${httpPort}."


docker-compose -f "${dockerComposeFile}" up -d
sleep 5

echo
echo " -------------  Looks good  ------------- "
echo
echo "TestRail should be available now on http://localhost:${httpPort}"
echo
echo "If your firewall is not blocking the port, it should also be reachable via:"

#####################################
# getting network adapters IPs to quickly provide TestRail links

netAdapters=$(ip -o link show | awk -F': ' '{print $2}')
(IFS='
'
for adapter in ${netAdapters}
do
  :
    if [ $adapter == "lo" ] || [[ $adapter == "docker"* ]] || [[ $adapter == "br-"* ]] || [[ $adapter == "veth"* ]]; then
        continue
    fi

    ip=$(ip addr | grep inet | grep "${adapter}" | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
    echo "  -->  http://${ip}:${httpPort}"
done
)

echo
echo "Please use the following values during TestRail setup:"
echo
echo "  DATABASE SETTINGS"
echo "    Server:     'db:3306'"
echo "    Database:   'testrail'"
echo "    User:       'testrail'"
echo "    Password:    <The user password you've entered for the db-user>"

echo
echo " CASSANDRA SETTINGS"
echo "    Server:     'cassandra'"
echo "    Port:       9042"
echo "    Keyspace:   'tr_keyspace'"
echo "    User:       'cassandra'"
echo "    Password:   'cassandra'"

echo
echo "  Application Settings"
echo "    - Simply leave the default values for the folders 'logs, reports, attachments and audit'."
echo
echo "  The TestRail background task is also automatically started 60s after the installation is done."
echo
echo
echo "To shut down TestRail again run the following command in this folder:"
echo "docker-compose down -v"