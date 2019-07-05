#!/usr/bin/env bash

echo
echo "##################################################################################"
echo " TestRail clenup"
echo
echo " This script will do a cleanup and remove eveything in _opt, _mysql + the config.php and the .env file."
echo " It will also shut down TestRail"
echo " You will need 'sudo' installed to run this script."
echo
echo
echo " Use this script with caution!"
echo " BE AWARE THAT THIS CAN NOT BE UN-DONE!"
echo
echo "###################################################################################"
echo

read -p "   Type 'yes' to continue or use 'Ctrl+C' to abort: " confirm

if [ "$confirm" = 'yes' ]; then
    sudo rm -rf _opt/* _mysql/* _config/config.php
    docker-compose down -v
else
    echo
    echo "Aborting..."
    exit -1
fi