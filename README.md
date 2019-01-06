# deno_docker

Docker files for [deno](https://github.com/denoland/deno).

These are published on Dockerhub at [hayd/deno](https://hub.docker.com/r/hayd/deno).

For example:

```Dockerfile
FROM hayd/deno:alpine-0.2.5

EXPOSE 1993

WORKDIR /app
ADD . /app

ENTRYPOINT ["deno", "--allow-net", "main.ts"]
```

and run locally:

```sh
$ docker build -t app . && docker run -it --init -p 1993:1993 app
```

See example directory.
