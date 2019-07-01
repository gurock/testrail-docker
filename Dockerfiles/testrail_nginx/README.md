# Testrail nginx image

To be extendeded...

## How to build the image?

The build supports `ARG_NGINX_VERSION` and `ARG_URL` as arguments as shown below.

```
docker build --build-arg ARG_NGINX_VERSION=latest --build-arg ARG_URL='https://secure.gurock.com/downloads/testrail/testrail-latest-ion70.zip' -t testrail/nginx:latest .
```
__Please note:__ When proving a custom zip-file, ensure that it also fits the php-version used in the php-fpm container!