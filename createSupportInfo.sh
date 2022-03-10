#!/usr/bin/env bash

echo "##################################################################################"
echo " This script will create a quick dump with information that helps troubleshooting"
echo " Results will be put into the 'support-info.txt' file."
echo "###################################################################################"




supportFile="support-info.txt"

rm $supportFile

echo "-----------------------------------------------------" >> $supportFile
echo "Root directory:" >> $supportFile
ls -ahls ./ >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "_opt directory:" >> $supportFile
ls -ahls ./_opt >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "_mysql directory:" >> $supportFile
ls -ahls ./_mysql >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "_cassandra directory:" >> $supportFile
ls -ahls ./_cassandra >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "docker info:" >> $supportFile
docker info >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "docker containers:" >> $supportFile
docker ps -a >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "docker images:" >> $supportFile
docker images >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "docker volumes:" >> $supportFile
docker volume ls >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo ".env:" >> $supportFile


envFile=.env
if test -f "$envFile"; then
    cat $envFile >> $supportFile
else
    echo ".env file does not exist"  >> $supportFile
fi


echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "config.php in '_config' folder:" >> $supportFile

configFile=./_config/config.php
if test -f "$configFile"; then
    cat $configFile >> $supportFile
else
    echo "config.php not existent in '_config' folder"  >> $supportFile
fi


echo "-----------------------------------------------------" >> $supportFile

echo
echo "  --> File successfully created"
echo "      Please send this file over to TestRail support. Thank you."
echo

