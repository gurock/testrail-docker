# Testrail mariadb image

To be extendeded...

## How to build the image?

Just build it ;-)

```
docker build -t testrail/mariadb:latest .
```

## How to run the image

When starting the container, it accepts a URL, which points to a DB-dump, as the last argument.
The username, password, DB-name, and DB-host have to be configured in the `config.php` file when building the image.