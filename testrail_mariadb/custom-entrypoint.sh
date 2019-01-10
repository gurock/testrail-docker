#!/bin/bash
set -e

echo $@

if [ $# -gt 0 ]
  then
    for i in $@; do :; done
    dbDump=$i
    echo "DB dump argument:" $dbDump
    if [ "$dbDump" != "None" ]
      then
        wget --no-check-certificate -O /docker-entrypoint-initdb.d/db.sql $dbDump
        mv /config.php /var/www/testrail/config.php
    

      #remove last argument
      echo "###############################"
      echo "DB downloaded"
      length=$(($#-1))
      array=${@:1:$length}

      echo "Starting mariadb with the following arguments:"
      echo "${array}"
      echo "###############################"
      exec /docker-entrypoint.sh mysqld"${array}"
    fi
  else
    echo "No DB dump argument provided"
    echo "mysqld $@"
    exec /docker-entrypoint.sh mysqld"$@"
fi

