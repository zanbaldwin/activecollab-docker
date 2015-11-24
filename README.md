# [activeCollab][ac] for [Docker][docker]

Docker container for self-hosted activeCollab.

## Linked Containers

This container links to other containers to provide MySQL and Elasticsearch functionality.

```bash
$ docker run -d --restart="always" --name="acmysql" -e "MYSQL_ROOT_PASSWORD=<yourPassword>" mysql:latest
$ docker run -d --restart="always" --name="acelastica" elasticsearch:latest
```

## Building

Super simple!

```bash
docker build --no-cache --rm -t zanderbaldwin/activecollab .
```

## Setting Up activeCollab

Because you need to be logged in to your activeCollab account to download it, setup is a manual process.

Extract the contents of the activeCollab download to a location of your choice, this will be known as
`$ACTIVECOLLAB_EXTRACTION_DIR`.

That's it.

## Running

```bash
docker run \
    --detach \
    --restart="always" \
    --name="activecollab" \
    --link="acmysql" \
    --link="acelastica" \
    --volume "$ACTIVECOLLAB_EXTRACTION_DIR:/var/www" \
    -p 32922:80 \
    zanderbaldwin/activecollab
```

Then add the following Nginx site configuration on the host machine:

```nginx
server {
    listen       80;
    server_name  $DOMAIN;

    access_log   /var/log/nginx/$DOMAIN.access.log;
    error_log    /var/log/nginx/$DOMAIN.error.log;

    location / {
        proxy_pass           http://localhost:32922;
        proxy_next_upstream  error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect       off;
        proxy_buffering      off;
        proxy_set_header     Host            $host;
        proxy_set_header     X-Real-IP       $remote_addr;
        proxy_set_header     X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## Warning

In order to pass the installation validation, the container must be able to resolve the domain you use to an IP that is
not `127.0.0.1`. To check that the domain you have chosen meets this requirement, execute the following:

```bash
$ docker exec activecollab ping $DOMAIN
```

[ac]: https://activecollab.com
[docker]: https://www.docker.com
