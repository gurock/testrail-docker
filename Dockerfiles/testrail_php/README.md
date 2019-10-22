# Testrail PHP-FPM image

To be extendeded...

## How to build the image?

The build supports `ARG_PHP_VERSION` and `ARG_IONCUBE_VERSION` as arguments as shown below.

```
docker build --build-arg ARG_PHP_VERSION=7.2 --build-arg ARG_IONCUBE_VERSION=10.3.9 -t testrail/php:6.0
```