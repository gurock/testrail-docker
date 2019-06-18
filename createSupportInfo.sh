#!/usr/bin/env bash

echo "##################################################################################"
echo " This script will create a quick dump with information that helps troubleshooting"
echo " Results will be put into the 'support-info.txt' file."
echo " Pls. send this file over to TestRail support. Thank you."
echo "###################################################################################"

supportFile="support-info.txt"

rm $supportFile

echo "-----------------------------------------------------" >> $supportFile
echo "Root directory:" >> $supportFile
ls -hls ./ >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "_opt directory:" >> $supportFile
ls -hls ./_opt >> $supportFile
echo "-----------------------------------------------------" >> $supportFile

echo "" >> $supportFile
echo "-----------------------------------------------------" >> $supportFile
echo "_mysql directory:" >> $supportFile
ls -hls ./_mysql >> $supportFile
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
echo "config.php in '_config' folder:" >> $supportFile

configFile=./_config/config.php
if test -f "$configFile"; then
    cat $configFile >> $supportFile
else
    echo "Default file not existent in '_config' folder"  >> $supportFile
fi

echo "-----------------------------------------------------" >> $supportFile

