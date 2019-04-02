#!/bin/bash
set -e

first_arg=$1
echo "$firstarg"  ${#first_arg}

if [ $# -gt 0 ] && [ "${#first_arg}" != 0 ]
  then
    for i in $@; do :; done
    dbDump=$i
    echo "DB dump argument:" $dbDump
    if [ "$dbDump" != "None" ]
      then
        wget --no-check-certificate -O /docker-entrypoint-initdb.d/db.sql $dbDump

      #remove last argument
      echo "###############################"
      echo "DB downloaded"
      length=$(($#-1))
      array=${@:1:$length}

      echo "Starting mysql with the following arguments:"
      echo "${array}"
      echo "###############################"
      exec docker-entrypoint.sh mysqld"${array}"
    fi
  else
    echo "No DB dump argument provided"
    echo "mysqld $@"
    exec docker-entrypoint.sh mysqld"$@"
fi

