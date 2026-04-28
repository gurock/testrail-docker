# TestRail Reporting Docker Container

This folder contains Docker assets to create a TestRail Reporting application-only Docker image.

The docker image contains the application component of TestRail Reporting and should be started against an existing TestRail Reporting repository database.
The docker container can populate an empty database with the required TestRail Reporting on startup.

This Docker implementation is based on the [Yellowfin Application Only image](https://github.com/YellowfinBI/Docker/tree/master/Docker%20Files/yellowfinAppOnly) and uses the TestRail Reporting installer with pre-configured TestRail branding.

## Deployment Instructions

1. **Prepare the installer**:
   Download the latest TestRail Reporting Installer JAR file.
   Place the installer JAR file as `TestRailReportingInstallerServer.jar` in this directory.

2. **Build the Docker image**:
   ```bash
   docker build -t testrail-reporting:latest .
   ```

## Docker Compose Deployment

For a docker-compose deployment, see the [TestRailReporting-DockerCompose](../TestRailReporting-DockerCompose/README.md) module.
