# TestRail - let's put it in docker containers

## What's in this repository?
This repo contains Dockerfiles and compose files to spawn TestRail in docker containers. 
The compose files also use public available TestRail images (see [here](https://hub.docker.com/u/cbreit)).

## (Real) Quick start

Necessary steps:
  * [Install docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) +
    [docker-compose](https://docs.docker.com/compose/install/) (on Linux, using `pip` is recommended)
  * Create a `env` file with at least the mandatory variables (see below)
  * Run `docker-compose up` (*it will take a few minutes the very first time)*  
  You're done!  
  
  If the build was successful, TestRail should be accessible through:  
  [http://localhost:8000](http://localhost:8000)

To remove the instance, press `Ctrl+C` and then run `docker-compose down`. 

---

## How to use the compose files

### The .env file
It's suggested to create a local `.env` file, to specify user or machine specific variables 
(more see [here](https://docs.docker.com/compose/env-file/)). Syntax is simple: e.g. 'HTTP_PORT=8000'

Environment variables can also be set directly in the shell with the same syntax and then using  `docker-compose`.

**Optional variables are:**  

  * DB_PORT
  * HTTP_PORT
  * HTTPS_PORT
  * DB_URL
    *(e.g. http://internal.yourcompany.com/5.7.sql)*

### Pre-populated databases and TestRails `config.php`
Via the `DB_URL` variable, it's also possible to provide a SQL-dump to be downloaded by the container, 
so TestRail is already pre-configured.
For proper functionality, the `config.php` file needs to be provided for in this case by 'mounting' the file, 
available in the 'config' folder, to '/var/www/testrail/config.php' (just have a look at the compose file; 
there's a commented line) in `php`.
Ensure that the values in the `config.php` file match the database settings for user and password specified 
in the compose file in `db`.

### The Compose Files

**General usage:**
```
docker-compose up
docker-compose down
```
`up` starts the container; `down` stops everything.

**Additional useful options:**
  - `-v` *(remove volumes)* This is important to remove temporary volumes after shutdown and is recommended to be used.  
         <sub> *If the volumes should not be purged, don't use this parameter. However, be aware that this might 
         still cause some side effects.* </sub>  
  - `-f` *(file)*  Can be used to specify a different compose file (by default docker-compose.yml is used)
  - `-p` *(project)* Has to be used if multiple TestRail instances should be started.  
         <sub>
         <details><summary>Details</summary>   
         Otherwise docker-compose with interact with an already running container.
         The name of the folder docker-compose is started in (in this case 'internal-docker') is used as a 
         project name and is prepended to all spawned containers.
         </details>
         </sub>

----

## General remarks on the compose files
All compose files rely on three volumes -- `testrail` which contains the installation and gets 
mounted to `/var/www/testrail`, `opt_testrail`, which contains uploaded files etc. and gets mounted 
to `/opt/testrail`, and `db_testrail`, which contains the database and gets mounted to `/var/lib/mysql`.
Containers are connected though a `testrail` bridged network.
Start-order is important -- php needs to be first, followed by webserver and DB.



