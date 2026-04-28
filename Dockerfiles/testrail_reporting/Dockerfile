#######################################################################################################
#
# TestRail Reporting Application-Server Only Docker File
#
# An image that will create a new application server node, and connect to an existing TestRail Reporting
# repository database.
#
# Options can be passed to the image on startup with the -e command
#
#  JDBC_CLASS_NAME                  The java class file for the repository database JDBC connection
#
#  JDBC_CONN_URL                    The JDBC connection string for the repository database
#
#  JDBC_CONN_USER                   The JDBC user for the repository database
#
#  JDBC_CONN_PASS                   The JDBC password for the repository database (can be encrypted)
#
#  APP_MEMORY (Optional)			    Set maximum memory for application (in MB). 
#
#  LOG_LEVEL (Optional)   		    Set logfile verbosity. Options: INFO/DEBUG/ERROR/WARN/TRACE
#
#  JDBC_CONN_ENCRYPTED (Optional)   Whether the database password is encrypted or not. Defaults to false
#
#  JDBC_MAX_COUNT (Optional)        Maximum connection pool size for the repository database connection pool. Defaults to 25
#
#  WELCOME_PAGE (Optional)          The default landing page for the application. Defaults to index_mi.jsp
#
#  APP_SERVER_PORT (Optional)       The HTTP port for the application. Defaults to 8080
#
#  APP_SHUTDOWN_PORT (Optional)     The shutdown port for the application. Defaults to 8083
#
#  PROXY_PORT (Optional)			    External proxy port
#
#  PROXY_SCHEME (Optional)          External proxy scheme (http or https)
#
#  PROXY_HOST (Optional)			    External proxy address
#
#  SECURE_ENABLED (Optional)	        Enable secure=true in tomcat connector configuration
#
#  SAMESITE_COOKIE_MODE (Optional)  Set Same-Site cookie mode. Options: unset/none/lax/strict   Default: none
#
#  CLUSTER_ADDRESS (Optional)	    Set cluster communication TCP address for node
# 
#  CLUSTER_PORT (Optional) 	        Set cluster communication TCP port. Unique for this container. 
#
#  CLUSTER_INTERFACE (Optional)     Set cluster communication network interface. Default: eth0
#
#  NODE_BACKGROUND_TASKS (Optional) Define the types of background tasks that can run on this cluster node
#
#  NODE_PARALLEL_TASKS (Optional)   Define the number of parallel task that can run on this cluster node
#
#  LIBRARY_ZIP (Optional)           Deploy additional file assets into the application server library folder from a specific URL
#
#  CONTENT_ZIP (Optional)           Deploy additional file assets into the application server folder structure from a specific URL
#
#  SKIP_OS_PACKAGE_UPGRADE (Optional) Skip operating system package upgrades on node startup
# 
#  IMPORT_DATASOURCE_URL   (Optional) Override initial content datasource URL 
#
#  IMPORT_DATASOURCE_USER   (Optional) Override initial content datasource username
#
#  IMPORT_DATASOURCE_PASS   (Optional) Override initial content datasource password
#
#######################################################################################################


#######################################################################################################
# Fetch the base operating system
#
# The installer can be downloaded during provisioning, or by providing the JAR file as part of image
#######################################################################################################

# From Ubuntu LTS base image
FROM ubuntu:24.04
LABEL maintainer="TestRail <support@testrail.com>"
LABEL description="TestRail Reporting Application Only"
ARG TARGETPLATFORM

# Timezone setup
ENV TZ=Etc/GMT

RUN <<EOT
 #Setup OS Packages
 #Apply Timezone
 ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

 #Install OS applications required for application installation and setup Java
 apt-get update -y
 apt-get upgrade -y 
 apt-get install -y wget unzip tar curl sed fonts-dejavu fontconfig liboss4-salsa-asound2 libglib2.0-0 libpangoft2-1.0-0 -y 
EOT


RUN <<EOT
 #Install Java 
 mkdir /usr/lib/jvm -p 
 echo $TARGETPLATFORM
 cd /usr/lib/jvm/ 
 if [ "$TARGETPLATFORM" = "linux/amd64" ]; then curl -o zuluJava.tar.gz https://cdn.azul.com/zulu/bin/zulu21.42.19-ca-fx-jdk21.0.7-linux_x64.tar.gz; fi; 
 if [ "$TARGETPLATFORM" = "linux/arm64" ]; then curl -o zuluJava.tar.gz https://cdn.azul.com/zulu/bin/zulu21.42.19-ca-fx-jdk21.0.7-linux_aarch64.tar.gz; fi; 

 #Configure Java using Zulu 21 JDK
 cd /usr/lib/jvm/
 mkdir zulu-jdk
 tar -xzf zuluJava.tar.gz -C zulu-jdk --strip-components=1
 rm zuluJava.tar.gz
EOT

ENV JAVA_HOME=/usr/lib/jvm/zulu-jdk/
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV CREATE_DATABASE_ON_INSTALL=false
ENV DATABASE_HOST=localhost
ENV DATABASE_PORT=0
ENV DATABASE_NAME=reporting

#######################################################################################################
# Fetch the TestRail Reporting installer
#
# The installer can be downloaded during provisioning, or by providing the JAR file as part of image
#######################################################################################################

# Alternatively copy in an installer that has been included image
# (This will remove the wait time for downloading the installer during image creation)
# Example syntax for copying in an embedded installer:
COPY TestRailReportingInstallerServer.jar /tmp/testrail-reporting-installer.jar

#######################################################################################################
# Perform filesystem installation
#
# Extract assets directly from TestRail Reporting installer JAR onto filesystem.
#######################################################################################################
RUN <<EOT
 #Extract TestRail Reporting
 mkdir -p /opt/testrailreporting /tmp/trr_temp /tmp/trr_temp2/appserver/webapps/ROOT /opt/testrailreporting/appserver/logs
 #Perform application extraction
 unzip /tmp/testrail-reporting-installer.jar -d /tmp/trr_temp  
 unzip /tmp/trr_temp/yfres/yellowfin.zip -d /tmp/trr_temp2 
 unzip /tmp/trr_temp2/yellowfin.war -d /tmp/trr_temp2/appserver/webapps/ROOT 
 cp /tmp/trr_temp/yfres/jdbc-drivers/* /tmp/trr_temp2/appserver/webapps/ROOT/WEB-INF/lib 
 rm /tmp/trr_temp2/yellowfin.war && cp -a /tmp/trr_temp2/* /opt/testrailreporting/ 
 rm -rf /tmp/trr_temp /tmp/trr_temp2 
 chmod +x /opt/testrailreporting/appserver/bin/catalina.sh /opt/testrailreporting/appserver/bin/startup.sh /opt/testrailreporting/appserver/bin/shutdown.sh
EOT

#######################################################################################################
# Build inline installation script
#
# Generate a silent installation script for when a repository database is not populated
#######################################################################################################
COPY <<EOF /opt/testrailreporting/tools/silent-install.properties 
InstallPath=/tmp/installation 
InstallTutorialDatabase=false 
ServicePort=5555 
InstallService=false 
DatabaseType={DATABASE_TYPE} 
CreateYellowfinDB={CREATE_DATABASE_ON_INSTALL}
CreateYellowfinDBUser=false
DatabaseHostname={DATABASE_HOST} 
DatabaseName={DATABASE_NAME} 
DatabasePort={DATABASE_PORT} 
#DatabaseConnectionString={DATABASE_URL} 
AppMemory=2048 
DatabaseDBAUser={DATABASE_USER} 
DatabaseDBAPassword={DATABASE_PASSWORD} 
DatabaseUser={DATABASE_USER}
DatabasePassword={DATABASE_PASSWORD}  
JdbcDriverFiles={JDBC_DRIVER_FILES}
EOF

COPY <<EOF /opt/testrailreporting/tools/db-type-from-url.sh
#!/bin/sh 
url=\$1
if [[ "\$url" =~ "jdbc:postgres" ]]; then
  echo "PostgreSQL"
elif [[ "\$url" =~ "jdbc:mysql" ]]; then
  echo "MySQL"
elif [[ "\$url" =~ "jdbc:hsqldb" ]]; then
  echo "HSQLDB"
elif [[ "\$url" =~ "jdbc:sqlserver" ]]; then
  echo "SQLServer"
elif [[ "\$url" =~ "jdbc:oracle:" ]]; then
  echo "Oracle"
elif [[ "\$url" =~ "jdbc:db2:" ]]; then
  echo "DB2"
else
  echo ""
fi
EOF



#######################################################################################################
# Build inline installation script
#
# Generate a silent installation script for when a repository database is not populated
#######################################################################################################
COPY <<EOF /opt/testrailreporting/tools/docker-entry.sh
#!/bin/bash 
echo ==== Test Existing Schema for \$JDBC_CONN_URL 
export CLASSPATH="/opt/testrailreporting/tools/ListDatabaseTables.jar:/opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/lib/*" 
java ListDatabaseTables url:\"\$JDBC_CONN_URL\" user:\"\$JDBC_CONN_USER\" password:\"\$JDBC_CONN_PASS\" > /opt/testrailreporting/tools/existing_tablelist 
head /opt/testrailreporting/tools/existing_tablelist
if grep -q 'ACCESSCLASSLIST' /opt/testrailreporting/tools/existing_tablelist ; then 
 echo 'Schema Exists - Aborting Installation';
 exit 1;
else 
 echo "Schema not detected - Creating repository database"
fi
echo ==== Prepare Installer Properties 
echo Set DBtype
databaseType=$(bash /opt/testrailreporting/tools/db-type-from-url.sh \"\$JDBC_CONN_URL\")
echo DatabaseType: \$databaseType
sed -i "s|{DATABASE_TYPE}|"\$databaseType"|g" /opt/testrailreporting/tools/silent-install.properties  
sed -i 's/{DATABASE_HOST}/'\"\$DATABASE_HOST\"'/g' /opt/testrailreporting/tools/silent-install.properties  
sed -i 's/{DATABASE_PORT}/'\"\$DATABASE_PORT\"'/g' /opt/testrailreporting/tools/silent-install.properties  
sed -i 's/{DATABASE_NAME}/'\"\$DATABASE_NAME\"'/g' /opt/testrailreporting/tools/silent-install.properties  
echo Set other stuff
#sed -i 's|{DATABASE_URL}|'\"\$JDBC_CONN_URL\"'|g' /opt/testrailreporting/tools/silent-install.properties 
sed -i 's|{DATABASE_USER}|'\"\$JDBC_CONN_USER\"'|g' /opt/testrailreporting/tools/silent-install.properties  
sed -i 's|{DATABASE_PASSWORD}|'\"\$JDBC_CONN_PASS\"'|g' /opt/testrailreporting/tools/silent-install.properties
sed -i 's|{CREATE_DATABASE_ON_INSTALL}|'\"\$CREATE_DATABASE_ON_INSTALL\"'|g' /opt/testrailreporting/tools/silent-install.properties
mySqlType="MySQL"
if [ "\$databaseType" == "\$mySqlType" ]; then
echo "Setting path to MySQL Driver"
sed -i 's|{JDBC_DRIVER_FILES}|/opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/lib/mysql-jdbc.jar|g' /opt/testrailreporting/tools/silent-install.properties
else 
sed -i 's|JdbcDriverFiles={JDBC_DRIVER_FILES}|#JdbcDriverFiles={JDBC_DRIVER_FILES}|g' /opt/testrailreporting/tools/silent-install.properties
fi
echo ==== Silent Installer Properties 
cat /opt/testrailreporting/tools/silent-install.properties
echo ==== Installing TestRail Reporting 
java -jar /tmp/testrail-reporting-installer.jar -silent /opt/testrailreporting/tools/silent-install.properties option.skipDataSourceValidation=true option.importDatasourceUsername=\"\$IMPORT_DATASOURCE_USER\" option.importDatasourcePassword=\"\$IMPORT_DATASOURCE_PASS\" option.importDatasourceUrl=\"\$IMPORT_DATASOURCE_URL\"
echo ==== Copying Log 
cp /tmp/installation/TestRail*ReportingInstallLog* /tmp
echo ==== Copying OOTB Content 
cp /tmp/installation/appserver/webapps/ROOT/META-INF/Content.yfx /tmp/Content.yfx
echo ==== Clean up installation files 
rm /tmp/testrail-reporting-installer.jar 
echo ==== Remove installation 
rm -r /tmp/installation 
echo ==== Installation Log 
cat /tmp/TestRail*ReportingInstallLog* 
if grep -q 'Installation Failed' /tmp/TestRail*Reporting*InstallLog*; then echo 'Installation Failed'; exit 1; fi 
echo Installation Successful   
exit 0 
EOF


# Create a script to build the connection string to pass to the ListDatabaseTables tool
COPY <<EOF /opt/testrailreporting/tools/build-connection-string.sh
#!/bin/sh
if [ \"PostgreSQL\" = \"\${DATABASE_TYPE}\" ]; then
echo jdbc:postgresql://\"\${DATABASE_HOST}\":\"\${DATABASE_PORT}\"/\"\${DATABASE_NAME}\" 
exit 0
fi
if [ \"MySQL\" = \"\${DATABASE_TYPE}\" ]; then 
echo jdbc:mysql://\"\${DATABASE_HOST}\":\"\${DATABASE_PORT}\"/\"\${DATABASE_NAME}\"
exit 0 
fi  
if [ \"SQLServer\" = \"\${DATABASE_TYPE}\" ]; then 
echo jdbc:sqlserver://\"\${DATABASE_HOST}\":\"\${DATABASE_PORT}\"/\"\${DATABASE_NAME}\" 
exit 0
fi
if [ \"Oracle\" = \"\${DATABASE_TYPE}\" ]; then 
echo oracle:thin:@\"\${DATABASE_HOST}\":\"\${DATABASE_PORT}\":\"\${DATABASE_NAME}\"  
exit 0 
fi   
echo Problem generating connection string  
exit 1  
EOF


#######################################################################################################
# Configuration
#
# Modify TestRail Reporting's configuration based on parameters passed to the docker container.
#######################################################################################################

COPY perform_docker_configuration.sh /opt/testrailreporting/appserver/bin
RUN <<EOT
 chmod +x /opt/testrailreporting/appserver/bin/perform_docker_configuration.sh
 sed -i 's/exec "$PRGDIR"\/"$EXECUTABLE" start "$@"/\/opt\/testrailreporting\/appserver\/bin\/perform_docker_configuration.sh\nexec "$PRGDIR"\/"$EXECUTABLE" run "$@"/g' /opt/testrailreporting/appserver/bin/startup.sh
EOT

#######################################################################################################
# Launch TestRail Reporting
#
# Start the TestRail Reporting application.
#######################################################################################################
WORKDIR /opt/testrailreporting/appserver/bin
CMD ["/opt/testrailreporting/appserver/bin/startup.sh"]
