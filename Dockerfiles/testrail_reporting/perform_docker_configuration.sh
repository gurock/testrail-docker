#!/bin/sh

if [ -z "${SKIP_OS_PACKAGE_UPGRADE}" ] || [ "${SKIP_OS_PACKAGE_UPGRADE}" = "FALSE" ] ; then
    echo "Updating Operating System Packages"
    apt-get update -y
	  apt-get upgrade -y
fi

COMPLETION_FILE=/opt/testrailreporting/appserver/bin/docker_configuration_done
if test -f "$COMPLETION_FILE"; then
    echo "Docker Configuration Error: $COMPLETION_FILE already exists, exiting"
else

################################################
# Fetch MySQL JDBC Driver
################################################
MYSQL_DRIVER_FILE=/opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/lib/mysql-jdbc.jar
if test -f "$MYSQL_DRIVER_FILE"; then
  echo "MySQL Driver already present"
else 
  wget --output-document $MYSQL_DRIVER_FILE https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.2.0/mysql-connector-j-8.2.0.jar
fi


################################################
# Initialize Repository Database
################################################
bash /opt/testrailreporting/tools/docker-entry.sh

CONTENT_FILE=/tmp/Content.yfx
if test -f "$CONTENT_FILE"; then
  echo "Moving initial content import file"
  mv /tmp/Content.yfx /opt/testrailreporting/appserver/webapps/ROOT/META-INF/Content.yfx
else 
  echo "Initial content import file $CONTENT_FILE not present"
fi


################################################
# Configuration changes to catalina.sh
################################################

# Replace ${installer.appname} Options with ""
sed -i 's/${installer.appname} Options//g' /opt/testrailreporting/appserver/bin/catalina.sh

# Replace JAVA_HOME="${JDKPath}" with ""
sed -i 's/JAVA_HOME="${JDKPath}"/#JAVA_HOME=Removed For Docker/g' /opt/testrailreporting/appserver/bin/catalina.sh

# Replace CATALINA_HOME="${INSTALL_PATH} with "CATALINA_HOME="/opt/testrailreporting/appserver"
sed -i 's/CATALINA_HOME="${INSTALL_PATH}\/appserver"/CATALINA_HOME="\/opt\/testrailreporting\/appserver"/g' /opt/testrailreporting/appserver/bin/catalina.sh

# Use Default Java Memory allocation, or set to the value of $APP_MEMORY
if [ ! -z "${APP_MEMORY}" ]; then
  # Replace JAVA_OPTS="$JAVA_OPTS -Xms128m -Xmx{APP_MEMORY}m
  sed -i 's/-Xmx${installer.app-server-memory}m/-Xmx'"$APP_MEMORY"'m/g' /opt/testrailreporting/appserver/bin/catalina.sh
else
  # Replace JAVA_OPTS="$JAVA_OPTS -Xms128m -Xmx${installer.app-server-memory}m" with "JAVA_OPTS="$JAVA_OPTS -Xms128m"
  sed -i 's/-Xmx${installer.app-server-memory}m//g' /opt/testrailreporting/appserver/bin/catalina.sh
fi

#Add JGroups Options under existing memory options
sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true -Djgroups.receive_on_all_interfaces=true"/g' /opt/testrailreporting/appserver/bin/catalina.sh

#Add External JGroups Address
if [ ! -z "${CLUSTER_ADDRESS}" ]; then
  sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djgroups.external_addr='"$CLUSTER_ADDRESS"'"/g' /opt/testrailreporting/appserver/bin/catalina.sh
fi

if [ ! -z "${CLUSTER_PORT}" ]; then
  sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djgroups.external_port='"$CLUSTER_PORT"'"/g' /opt/testrailreporting/appserver/bin/catalina.sh
fi

if [ ! -z "${CLUSTER_INTERFACE}" ]; then
  sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djgroups.bind_addr='"$CLUSTER_INTERFACE"'"/g' /opt/testrailreporting/appserver/bin/catalina.sh
else
  sed -i 's/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"/# JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=1024m"\n\nJAVA_OPTS="$JAVA_OPTS -Djgroups.bind_addr=match-interface:eth0"/g' /opt/testrailreporting/appserver/bin/catalina.sh
fi


################################################
# Configuration changes to web.xml
################################################

# Replace ${installer.webapp.url} with "/opt/testrailreporting/appserver/webapps/ROOT"
sed -i 's/${installer.webapp.url}/\/opt\/testrailreporting\/appserver\/webapps\/ROOT/g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${installer.additional.bof.settings} with ""
sed -i 's/${installer.additional.bof.settings}//g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${jdbc-conn-properties} with ""
sed -i 's/${jdbc-conn-properties}//g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace <param-value>${installer.appname} Connection Pool</param-value> with "<param-value>Connection Pool</param-value>"
sed -i 's/<param-value>${installer.appname} Connection Pool<\/param-value>/<param-value>Connection Pool<\/param-value>/g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${welcome.file} with $WELCOME_PAGE or index_mi.jsp
if [ -z "${WELCOME_PAGE}" ]; then
  sed -i 's/${welcome.file}/index_mi.jsp/g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml
else
  sed -i 's@${welcome.file}@'"$WELCOME_PAGE"'@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml
fi

# Replace ${jdbc-class-name} with environment variable $JDBC_CLASS_NAME
sed -i 's/${jdbc-class-name}/'"$JDBC_CLASS_NAME"'/g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${jdbc-conn-url} with environment variable $JDBC_CONN_URL
sed -i 's|${jdbc-conn-url}|'"$JDBC_CONN_URL"'|g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${config-user-userid} with environment variable $JDBC_CONN_USER
sed -i 's/${config-user-userid}/'"$JDBC_CONN_USER"'/g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${config-user-passwd} with environment variable $JDBC_CONN_PASS
sed -i 's/${config-user-passwd}/'"$JDBC_CONN_PASS"'/g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml

# Replace ${config-user-passwd-encryption} with environment variable $JDBC_CONN_ENCRYPTED
if [ -z "${JDBC_CONN_ENCRYPTED}" ]; then
  sed -i 's/${config-user-passwd-encryption}/false/g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml
else
  sed -i 's/${config-user-passwd-encryption}/'"$JDBC_CONN_ENCRYPTED"'/g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml
fi

# Replace <param-value>25</param-value> with <param-value>$JDBC_MAX_COUNT</param-value>
if [ ! -z "${JDBC_MAX_COUNT}" ]; then
  sed -i 's@<param-value>25</param-value>@<param-value>'"$JDBC_MAX_COUNT"'</param-value>@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml
fi


#
#   Insert Cluster Management Servlet
#
# <!-- Cluster Management -->
#<servlet>
#       <servlet-name>ClusterManagement</servlet-name>
#       <servlet-class>com.hof.mi.servlet.ClusterManagement</servlet-class>
#       <init-param>
#             <param-name>ClusterType</param-name>
#             <param-value>REPOSITORY</param-value>
#       </init-param>
#       <init-param>
#             <param-name>SerialiseWebserviceSessions</param-name>
#             <param-value>true</param-value>
#       </init-param>
#       <init-param>
#             <param-name>CheckSumRows</param-name>
#             <param-value>true</param-value>
#       </init-param>
#       <init-param>
#             <param-name>EncryptSessionId</param-name>
#             <param-value>true</param-value>
#       </init-param>
#       <init-param>
#             <param-name>EncryptSessionData</param-name>
#             <param-value>true</param-value>
#       </init-param>
#       <init-param>
#             <param-name>AutoTaskDelegation</param-name>
#             <param-value>true</param-value>
#       </init-param>
#		<init-param>
#              <param-name>TaskTypes</param-name>
#              <param-value>
#                     REPORT_BROADCAST_BROADCASTTASK,
#                     REPORT_BROADCAST_MIREPORTTASK,
#                     FILTER_CACHE,
#                     SOURCE_FILTER_REFRESH,
#                     SOURCE_FILTER_UPDATE_REMINDER,
#                     THIRD_PARTY_AUTORUN,
#                     ORGREF_CODE_REFRESH,
#                     ETL_PROCESS_TASK,
#                     SIGNALS_DCR_TASK,
#                     SIGNALS_ANALYSIS_TASK,
#                     SIGNALS_CLEANUP_TASK,
#                     COMPOSITE_VIEW_REFRESH,
#                     SIGNALS_CORRELATION_TASK
#              </param-value>
#       </init-param>
#       <init-param> 
#              <param-name>MaxParallelTaskCounts</param-name> 
#              <param-value>
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2,
#                     2
#              </param-value>
#       </init-param> 
#       <load-on-startup>11</load-on-startup>
# </servlet>

# Replace <!-- Web Services Servlet --> with Cluster Management XML
sed -i 's@<!-- Web Services Servlet -->@<servlet>\n       <servlet-name>ClusterManagement</servlet-name>\n       <servlet-class>com.hof.mi.servlet.ClusterManagement</servlet-class>\n       <init-param>\n             <param-name>ClusterType</param-name>\n             <param-value>REPOSITORY</param-value>\n       </init-param>\n       <init-param>\n             <param-name>SerialiseWebserviceSessions</param-name>\n             <param-value>true</param-value>\n       </init-param>\n       <init-param>\n             <param-name>CheckSumRows</param-name>\n             <param-value>true</param-value>\n       </init-param>\n       <init-param>\n             <param-name>EncryptSessionId</param-name>\n             <param-value>true</param-value>\n       </init-param>\n       <init-param>\n             <param-name>EncryptSessionData</param-name>\n             <param-value>true</param-value>\n       </init-param>\n       <init-param>\n             <param-name>AutoTaskDelegation</param-name>\n             <param-value>true</param-value>\n       </init-param>\n      <load-on-startup>11</load-on-startup>\n   </servlet>\n\n<!-- Web Services Servlet -->@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml


# Add TaskTypes with environment variable $NODE_BACKGROUND_TASKS, or inserts the default
if [ -z "${NODE_BACKGROUND_TASKS}" ]; then
  sed -i 's@<load-on-startup>11@ <init-param>\n             <param-name>TaskTypes</param-name>\n             <param-value>\nREPORT_BROADCAST_BROADCASTTASK,\nREPORT_BROADCAST_MIREPORTTASK,\nFILTER_CACHE,\nSOURCE_FILTER_REFRESH,\nSOURCE_FILTER_UPDATE_REMINDER,\nTHIRD_PARTY_AUTORUN,\nORGREF_CODE_REFRESH,\nETL_PROCESS_TASK,\nSIGNALS_DCR_TASK,\nSIGNALS_ANALYSIS_TASK,\nSIGNALS_CLEANUP_TASK,\nCOMPOSITE_VIEW_REFRESH,\nSIGNALS_CORRELATION_TASK\n             </param-value>\n       </init-param>\n      <load-on-startup>11@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml
else
  sed -i 's@<load-on-startup>11@ <init-param>\n             <param-name>TaskTypes</param-name>\n             <param-value>'"$NODE_BACKGROUND_TASKS"'</param-value>\n       </init-param>\n      <load-on-startup>11@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml
fi

# Add MaxParallelTaskCounts with environment variable $NODE_PARALLEL_TASKS, or inserts the default
if [ -z "${NODE_PARALLEL_TASKS}" ]; then
  sed -i 's@<load-on-startup>11@ <init-param>\n             <param-name>MaxParallelTaskCounts</param-name>\n             <param-value>2,2,2,2,2,2,2,2,2,2,2,2,2</param-value>\n       </init-param>\n      <load-on-startup>11@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml
else
  sed -i 's@<load-on-startup>11@ <init-param>\n             <param-name>MaxParallelTaskCounts</param-name>\n             <param-value>'"$NODE_PARALLEL_TASKS"'</param-value>\n       </init-param>\n      <load-on-startup>11@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml
fi

################################################
# PDF URL fix - web.xml - Connect to 9090 web connector
################################################

pdfPort=9090
pdfHost=localhost
pdfScheme=http

pdfUrl="${pdfScheme}://${pdfHost}:${pdfPort}/"
echo "PDF Url will be set to ${pdfUrl}"
sed -i 's@<load-on-startup>7</load-on-startup>@<init-param>\n <param-name>PdfUrl</param-name>\n <param-value>'$pdfUrl'</param-value> \n </init-param> \n <load-on-startup>7</load-on-startup> @g'  /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/web.xml


################################################
# Configuration changes to server.xml
################################################

# Replace ${app-server-port} with environment variable $APP_SERVER_PORT
if [ -z "${APP_SERVER_PORT}" ]; then
  sed -i 's/${app-server-port}/8080/g' /opt/testrailreporting/appserver/conf/server.xml
else
  sed -i 's/${app-server-port}/'"$APP_SERVER_PORT"'/g' /opt/testrailreporting/appserver/conf/server.xml
fi

# Replace ${app-server-shutdown-port} with environment variable $APP_SHUTDOWN_PORT
if [ -z "${APP_SHUTDOWN_PORT}" ]; then
  sed -i 's/${app-server-shutdown-port}/8083/g' /opt/testrailreporting/appserver/conf/server.xml
else
  sed -i 's/${app-server-shutdown-port}/'"$APP_SHUTDOWN_PORT"'/g' /opt/testrailreporting/appserver/conf/server.xml
fi


# Insert Proxy Port with environment variable $PROXY_PORT
if [ ! -z "${PROXY_PORT}" ]; then
  sed -i 's#maxThreads="150"#maxThreads="150" proxyPort="'"$PROXY_PORT"'"#g' /opt/testrailreporting/appserver/conf/server.xml
fi

# Insert Proxy Scheme with environment variable $PROXY_SCHEME
if [ ! -z "${PROXY_SCHEME}" ]; then
  sed -i 's#maxThreads="150"#maxThreads="150" scheme="'"$PROXY_SCHEME"'"#g' /opt/testrailreporting/appserver/conf/server.xml
fi


# Insert Proxy Host with environment variable $PROXY_HOST
if [ ! -z "${PROXY_HOST}" ]; then
  sed -i 's#maxThreads="150"#maxThreads="150" proxyName="'"$PROXY_HOST"'"#g' /opt/testrailreporting/appserver/conf/server.xml
fi

# Insert Secure attribute with value of environment variable $SECURE_ENABLED
if [ ! -z "${SECURE_ENABLED}" ]; then
  sed -i 's#maxThreads="150"#maxThreads="150" secure="'"$SECURE_ENABLED"'"#g' /opt/testrailreporting/appserver/conf/server.xml
fi


# Configure another connector for PDF generation on port 9090
#  <Connector port="9090" protocol="HTTP/1.1" connectionTimeout="20000" />

sed -i 's@<Service name="Catalina">@<Service name="Catalina">\n\n     <Connector port="9090" protocol="HTTP/1.1" connectionTimeout="20000" />\n@g' /opt/testrailreporting/appserver/conf/server.xml


################################################
# Configuration changes to ROOT.xml
################################################

# Replace ${INSTALL_PATH}/${installer.warfilename} with /opt/testrailreporting/appserver/webapps/ROOT
sed -i 's@${INSTALL_PATH}/${installer.warfilename}@/opt/testrailreporting/appserver/webapps/ROOT@g' /opt/testrailreporting/appserver/conf/Catalina/localhost/ROOT.xml


################################################
# Configuration changes to context.xml
################################################

# Insert Same-Site Cookie Mode into context.xml
if [ ! -z "${SAMESITE_COOKIE_MODE}" ]; then
	sed -i 's@<Context>@<Context>\n    <CookieProcessor sameSiteCookies="'"$SAMESITE_COOKIE_MODE"'" />@g' /opt/testrailreporting/appserver/conf/context.xml
fi


################################################
# Configuration changes to global web.xml
################################################

if [ ! -z "${SESSION_TIMEOUT}" ]; then
    sed -i 's@<session-timeout>30</session-timeout>@<session-timeout>'"$SESSION_TIMEOUT"'</session-timeout>@g' /opt/testrailreporting/appserver/conf/web.xml
fi


################################################
# Configuration changes to log4j settings
################################################


if [ -e "/opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/log4j.properties" ]; then
	# Replace {catalina.home}/ with /opt/testrailreporting/appserver
	sed -i 's@${catalina.home}@/opt/testrailreporting/appserver@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/log4j.properties
	# Replace ${installer.applogfilename}/ with testrailreporting.log
	sed -i 's@${installer.applogfilename}@testrailreporting.log@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/log4j.properties

	if [ ! -z "${LOG_LEVEL}" ]; then
		sed -i 's@$# log4j.category.com.hof=DEBUG@log4j.category.com.hof='"$LOG_LEVEL"'@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/log4j.properties
	fi

fi



if [ -e "/opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/log4j2.xml" ]; then
	# Replace {catalina.home}/ with /opt/testrailreporting/appserver
	sed -i 's@${catalina.home}@/opt/testrailreporting/appserver@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/log4j2.xml
	# Replace ${installer.applogfilename}/ with testrailreporting.log
	sed -i 's@${installer.applogfilename}@testrailreporting.log@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/log4j2.xml
	
	if [ ! -z "${LOG_LEVEL}" ]; then
		sed -i 's@INFO@'"$LOG_LEVEL"'@g' /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/log4j2.xml
	fi
fi

################################################
# Download additional libraries into WEB-INF/lib
################################################

# See if a URL for additional libraries has been passed
# The contents of the zip file will be unzipped into the WEB-INF/lib folder.
if [ ! -z "${LIBRARY_ZIP}" ]; then
  curl -qL $LIBRARY_ZIP -o /opt/testrailreporting/appserver/bin/additional_libraries.zip
  unzip /opt/testrailreporting/appserver/bin/additional_libraries.zip -d /opt/testrailreporting/appserver/webapps/ROOT/WEB-INF/lib
fi

# See if a URL for additional content has been passed
# The contents of the zip file will be unzipped into the ROOT folder, allowing content to be unzipped into child folders.
if [ ! -z "${CONTENT_ZIP}" ]; then
  curl -qL $CONTENT_ZIP -o /opt/testrailreporting/appserver/bin/additional_content.zip
  unzip /opt/testrailreporting/appserver/bin/additional_content.zip -d /opt/testrailreporting/appserver/webapps/ROOT
fi

################################################
# Write Completion Flag
################################################

touch /opt/testrailreporting/appserver/bin/docker_configuration_done
echo "Docker Configuration Complete"

fi
