# TestRail - let's put it in docker containers

## What's in this repository?
This repo contains Dockerfiles and compose files to spawn TestRail in docker containers.
The compose files rely on public available TestRail images available [here](https://hub.docker.com/r/testrail/apache).

## Requirements
  * [Install docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) +
    [docker-compose](https://docs.docker.com/compose/install/) (on Linux, using `pip` is recommended)
  * Some basic understanding of docker _(e.g knowing what containers, images, detached mode, ... are)_ <br/>
    &rarr; Official "Get Started" available [here](https://docs.docker.com/get-started)
  * Optional: If you're using the `quickstart.sh` script, also install `sudo` and  `ip` (usually pre-installed on most systems)

## Quick start with script
  * Run `quickstart.sh`
  * Type in two passwords -- one for the "normal" database user and one for root
  * Wait a few moments -- TestRail will be downloaded and set up

TestRail should be accessible via:  [http://localhost:8000](http://localhost:8000)

Finish the installation through the web UI (use the values printed by installer at the end)

## Running Testrail using docker-compose

The compose file is configured via environment variables -- it's suggested to use a .env file. More about such an .env file is available [here](https://docs.docker.com/compose/env-file/).

  * Create a `.env` file with at least the mandatory variables for:
    * DB_USER
    * DB_NAME
    * DB_PWD
    * DB_ROOT_PWD
  * Run `docker-compose up` (*it will take a few minutes the very first time)*
  You're done!

TestRail should be accessible via:  [http://localhost:8000](http://localhost:8000)

Re-enter the values you specified in the .env file when the TestRail installer asks for the database settings.
To remove the instance, press `Ctrl+C` and then run `docker-compose down`.

---

## Running TestRail with an external DB

If you'd like to just run TestRail and use a DB hosted on another server, in the cloud, starting TestRail is simple.
In this case, only `docker` is needed (not 'docker-compose', as mentioned above).

```
docker run -d --name testrail -p 8000:80 -v $PWD/_opt:/opt/testrail -v $PWD/_config:/var/www/testrail/config testrail/apache:latest
```
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
For proper functionality, the `config.php` file needs to be provided. Simply copy it into the `_config` folder.
Ensure that the values in the `config.php` file match the database settings for user and password, which are specified
in the compose file for the `db`.

### The Compose Files

**General usage:**
```
docker-compose up
docker-compose down
```
`up` starts the container; `down` stops everything. The docker-compose CLI reference can be found [here](https://docs.docker.com/compose/reference/).

**Additional useful options:**
  - `-v` *(remove named volumes)* This is important to remove temporary volumes after shutdown and is recommended to be used.
         <sub> *If the volumes should not be purged, don't use this parameter. However, be aware that this might
         still cause some side effects.* </sub>
  - `-f` *(file)*  Can be used to specify a different compose file (by default docker-compose.yml is used)
  - `-p` *(project)* Has to be used if multiple TestRail instances should be started.
         <details open><summary>Details</summary>
         Otherwise docker-compose with interact with an already running container.
         The name of the folder docker-compose is started in (in this case 'internal-docker') is used as a
         project name and is prepended to all spawned containers.
         </details>

**Recommendation:** Use `docker-compose down -v`, as it removes named and anonymous volumes!

----

## General remarks on the compose files
All compose files rely on additional volumes
  * `testrail_root` contains the installation and gets mounted to `/var/www/testrail`
  * `testrail_opt` contains uploaded files etc. and gets mounted  to `/opt/testrail`
  * `testrail_db` contains the database and gets mounted to `/var/lib/mysql`.
  * `testrail_cassandra` contains the Cassandra database and gets mounted to `/var/lib/cassandra`.
  * `testrail_config` contains the `config.php` file, which configures TestRail and is mounted to `/var/www/testrail/config`

Containers are connected though a `testrail` bridged network.
Start-order is important -- php needs to be first, followed by webserver and DB.



