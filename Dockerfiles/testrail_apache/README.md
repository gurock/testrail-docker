# Testrail Apache PHP-FPM image

To be extendeded...

## How to build the image?

The build supports `ARG_PHP_VERSION`, `ARG_IONCUBE_VERSION`, and `ARG_URL` as arguments as shown below.

```
docker build --build-arg ARG_PHP_VERSION=7.2 --build-arg ARG_IONCUBE_VERSION=10.3.9 --build-arg ARG_URL='https://secure.gurock.com/downloads/testrail/testrail-latest-ion70.zip' -t testrail/apache:6.0 .
```

__Please note:__ When proving a custom zip-file, ensure that it also fits the php-version provided!