#!/usr/bin/env bash

echo
echo "##################################################################################"
echo " TestRail quickstart"
echo " This script will help you to quickly start a TestRail instance and will"
echo " populate a '.env' file with the neccessary configuration values."
echo " For more advanced configuration please directly modify the .env file and utilize"
echo " docker-compose directly."
echo "###################################################################################"
echo


read -p "Press 'Enter' to continue (or Ctrl+C to abort)"
echo

dockerOutput=$(docker ps | grep testrail)

if [ -n "${dockerOutput}" ];
then
   echo " ### Seems like a TestRail instance is already running"
   echo "   To shut it down run 'docker-compose down -v' and then call this script again."
   echo
   read -n1 -r -p "Press 'c' to continue or any other key to abort..." key

   if [ "$key" = 'c' ]; then
        continue
    else
        exit -1
    fi
else
   echo "NOT OK";
fi


envFile=.env
timeStamp=$(date "+%Y.%m.%d-%H.%M.%S")
if test -f "$envFile"; then
    echo "A '.env' file already exists -- it will be saved and we'll create a new one"

    mv .env .env_$timeStamp
fi

touch .env

echo "An empty database named 'testrail' is automatically created together with the user 'testrail'."
echo "In succession, please enter a password for this user.
During the installation, use 'testrail' for the database name and the database-user and utilize the password you'll enter now."
echo
read -p "Enter a password for the database user: "  pwd

echo
echo "The database also needs a secure root password (needed for debugging/emergency cases)"
echo
read -p "Enter a database root password: "  root_pwd


echo "DB_USER=testrail" >> .env
echo "DB_NAME=testrail" >> .env
echo "DB_PWD=${pwd}"    >> .env
echo "DB_ROOT_PWD=${root_pwd}" >> .env

echo
echo "The database will be stored in the local folders '_mysql' and files created by TestRail will be placed in '_opt'."

dbFolder=_mysql
dbFiles=(./_mysql/*)
shopt -s nullglob dotglob
if [ ${#dbFiles[@]} -gt 0 ]; then
    echo " ### The db-folder already contains files -- saving the folder now (pls delete it later if you don't need it anymore)"

    mv $dbFolder "${dbFolder}_${timeStamp}"
    mkdir -p $dbFolder
fi

echo "OPT_PATH=_opt"  >> .env
echo "MYSQL_PATH=_mysql"  >> .env
echo "TESTRAIL_VERSION=latest" >> .env


echo
echo "TestRail will be started now with HTTP and will listen on port 8000."
httpPort=8000

echo "HTTP_PORT=${httpPort}"  >> .env

docker-compose up -d
sleep 5

echo
echo " -------------  Looks good  ------------- "
echo
echo "TestRail should be available now on http://localhost:$httpPort"
echo
echo "If your firewall is not blocking the port, it should also be reachable via:"

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
    echo "  http://${ip}:${httpPort}"
done
)

echo
echo "Please use the following values during TestRail setup:"
echo
echo "  DATABASE SETTINGS"
echo "    Server:     'db:3306'"
echo "    Database:   'testrail'"
echo "    User:       'testrail'"
echo "    Password:    <The user password you've entered before>"

echo
echo "  Application Settings"
echo "    Attachment Directory:    '/opt/testrail/attachments'"
echo "    Report Directory:        '/opt/testrail/reports'"
echo "    Log Directory:           '/opt/testrail/logs'"
echo "    Audit Directory:         '/opt/testrail/audit'"


echo
echo
echo "To shut down TestRail again run the following command in this folder:"
echo "docker-compose down -v"

















