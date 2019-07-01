<?php

/*
|--------------------------------------------------------------------
| DATABASE CONFIGURATION
|--------------------------------------------------------------------
|
| Please specify the database connection settings below. Currently
| supported databases are SQL Server (2008, 2012, 2014, 2016) and
| MySQL (5.x).
*/

define('DB_DRIVER', 'mysql'); // sqlsrv or mysql
define('DB_HOSTNAME', 'db:3306');
define('DB_DATABASE', 'testrail');
define('DB_USERNAME', 'testrail');
define('DB_PASSWORD', 'testrail');

/*
|--------------------------------------------------------------------
| DIAGNOSTICS
|--------------------------------------------------------------------
|
| The following settings configure the logging and error behavior
| of TestRail.
*/

define('LOG_PATH', '/opt/testrail/logs/');
define('AUDIT_PATH', '/opt/testrail/audit/');

/*
|--------------------------------------------------------------------
| OPTIMIZATIONS
|--------------------------------------------------------------------
|
| You can choose whether to optimize the delivery of style sheet and
| javascript files and the handling of language files. The following
| optimization settings are available:
|
| DEPLOY_OPTIMIZE_LANG:   If enabled, TestRail uses a single combined
|                         language file named 'all_lang' instead of
|                         multiple language files.
|
| DEPLOY_OPTIMIZE_CSS:    If enabled, a single combined style sheet
|                         is served to the clients.
|
| DEPLOY_OPTIMIZE_JS:     If enabled, a single combined javascript
|                         file is served to the clients.
*/

define('DEPLOY_OPTIMIZE_LANG', true);
define('DEPLOY_OPTIMIZE_CSS', true);
define('DEPLOY_OPTIMIZE_JS', true);
