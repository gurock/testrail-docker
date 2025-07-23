#!/usr/bin/env bash

timeStamp=$(date "+%Y.%m.%d-%H.%M.%S")
dbFolder=_mysql
optFolder=_opt
confFolder=_config
# value for the variable cassandraDeprecationVersion will need to be updated with actual deprecation version.
cassandraDeprecationVersion="9.4.0"
cassandraIsDeprecated="true"

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

# Normalize versions to 3-part format (e.g., 9 -> 9.0.0, 9.0 -> 9.0.0)
normalize_version() {
    echo "$1" | awk -F. '{ printf("%d.%d.%d\n", $1, $2?$2:0, $3?$3:0) }'
}

version=$(normalize_version "$version")
cassandraDeprecationVersion=$(normalize_version "$cassandraDeprecationVersion")

if [ "$(printf '%s\n' "$version" "$cassandraDeprecationVersion" | sort -V | head -n1)" == "$version" ] && [ "$version" != "$cassandraDeprecationVersion" ]; then
    cassandraIsDeprecated="false"
else
    echo "Cassandra Deprecation Applied for Provided Testrail Version '${version}'"
fi

echo
echo "###########################################################################################"
echo " If you're upgrading from a docker applicance, simply continue. Otherwise, do these steps:"
echo "   * Ensure that the 'config.php' file is in the '_config folder'."
echo "   * Copy the content of /var/lib/mysql to '_mysql'"
echo "     (if you're using a dedicated mysql server for TestRail -- otherwise do a manual upgrade)"
if [ "$cassandraIsDeprecated" == "false" ]; then
    echo "   * Copy the content of /var/lib/cassandra to '_cassandra'"
fi
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
if [ "$cassandraIsDeprecated" == "true" ]; then
    docker-compose -f docker-compose.yml up -d
else
    docker-compose -f docker-compose.yml -f docker-compose-override-cassandra.yml up -d
fi

echo
echo "We're done :-)"