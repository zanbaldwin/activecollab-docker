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
    listen          80;

    server_name     $DOMAIN;
    server_tokens   off;

    access_log      /var/log/nginx/$DOMAIN.access.log;
    error_log       /var/log/nginx/$DOMAIN.error.log;

    location / {
        proxy_pass           http://localhost:32922;
        proxy_next_upstream  error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect       off;
        proxy_buffering      off;
        proxy_set_header     Host            $host;
        proxy_set_header     X-Real-IP       $remote_addr;
        proxy_set_header     X-Forwarded-For $proxy_add_x_forwarded_for;
        ## If you use HTTPS, the following line *MUST* be set to pass URL rewriting verification!
        # proxy_set_header     X-Real-Port     443;
    }
}
```

If you wish to use HTTPS, the replace `listen 80;` with the following:

```nginx
listen                      443 ssl;
ssl                         on;
ssl_protocols               TLSv1 TLSv1.1 TLSv1.2;
ssl_session_cache           builtin:1000 shared:SSL:10m;
ssl_prefer_server_ciphers   on;
ssl_dhparam                 /etc/ssl/certs/dhparam.pem;
ssl_ciphers                 'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:MD5:!PSK:!RC4';
add_header                  Strict-Transport-Security max-age=63072000;
add_header                  X-Frame-Options DENY;
add_header                  X-Content-Type-Options nosniff;
ssl_certificate             /etc/ssl/private/$DOMAIN.crt;
ssl_certificate_key         /etc/ssl/private/$DOMAIN.key;
```

## Warning

In order to pass the installation validation, the container must be able to resolve the domain you use to an IP that is
not `127.0.0.1`. To check that the domain you have chosen meets this requirement, execute the following:

```bash
$ docker exec activecollab ping $DOMAIN
```

[ac]: https://activecollab.com
[docker]: https://www.docker.com
