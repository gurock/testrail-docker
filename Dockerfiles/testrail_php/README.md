# Testrail PHP-FPM image

To be extendeded...

## How to build the image?

The build supports `ARG_PHP_VERSION` and `ARG_IONCUBE_VERSION` as arguments as shown below.

```
docker build --build-arg ARG_PHP_VERSION=7.0 --build-arg ARG_IONCUBE_VERSION=10.2.4 -t testrail/php:7.0-fpm .
```