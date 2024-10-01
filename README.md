# deno_docker

Docker files for [Deno](https://github.com/denoland/deno) published on
Dockerhub:

- Alpine Linux: [denoland/deno:alpine](https://hub.docker.com/r/denoland/deno)
- Debian: [denoland/deno:debian](https://hub.docker.com/r/denoland/deno)
  (default)
- Distroless: [denoland/deno:distroless](https://hub.docker.com/r/denoland/deno)
- Ubuntu: [denoland/deno:ubuntu](https://hub.docker.com/r/denoland/deno)
- Only the binary: [denoland/deno:bin](https://hub.docker.com/r/denoland/deno)

![ci status](https://github.com/denoland/deno_docker/workflows/ci/badge.svg?branch=main)

---

## Run locally

To start the `deno` repl:

```sh
$ docker run -it denoland/deno:2.0.0-rc.9 repl
```

To shell into the docker runtime:

```sh
$ docker run -it denoland/deno:2.0.0-rc.9 sh
```

To run `main.ts` from your working directory:

```sh
$ docker run -it -p 1993:1993 -v $PWD:/app denoland/deno:2.0.0-rc.9 run --allow-net /app/main.ts
```

Here, `-p 1993:1993` maps port 1993 on the container to 1993 on the host,
`-v $PWD:/app` mounts the host working directory to `/app` on the container, and
`--allow-net /app/main.ts` is passed to deno on the container.

## As a Dockerfile

```Dockerfile
FROM denoland/deno:2.0.0-rc.9

# The port that your application listens to.
EXPOSE 1993

WORKDIR /app

# Prefer not to run as root.
USER deno

# Cache the dependencies as a layer (the following two steps are re-run only when deps.ts is modified).
# Ideally cache deps.ts will download and compile _all_ external files used in main.ts.
COPY deps.ts .
RUN deno cache deps.ts

# These steps will be re-run upon each file change in your working directory:
COPY . .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

CMD ["run", "--allow-net", "main.ts"]
```

and build and run this locally:

```sh
$ docker build -t app . && docker run -it -p 1993:1993 app
```

## Using your own base image

If you prefer to install `deno` in your own base image, you can use the
`denoland/deno:bin` to simplify the process.

```Dockerfile
FROM ubuntu
COPY --from=denoland/deno:bin-2.0.0-rc.9 /deno /usr/local/bin/deno
```

## Running on Google Cloud Run(GCR)
Due to conflicts with google cloud run caching mechanism it's required to use different path for `DENO_DIR` in your Dockerfile. 

```Dockerfile
# set DENO_DIR to avoid conflicts with google cloud
ENV DENO_DIR=./.deno_cache
```

Without it GCR instance will try to download deps every time. When running with `--cached-only` you will get `Specified not found in cache`.

## (optional) Add `deno` alias to your shell

Alternatively, you can add `deno` command to your shell init file (e.g.
`.bashrc`):

```sh
deno () {
  docker run \
    --interactive \
    --tty \
    --rm \
    --volume $PWD:/app \
    --volume $HOME/.deno:/deno-dir \
    --workdir /app \
    denoland/deno:2.0.0-rc.9 \
    "$@"
}
```

and in your terminal

```sh
$ source ~/.bashrc
$ deno --version
$ deno run ./main.ts
```

---

See example directory.

Note: Dockerfiles provide a USER `deno` and DENO_DIR is set to `/deno-dir/`
(which can be overridden).

_If running multiple Deno instances within the same image you can mount this
directory as a shared volume._

## Thanks

Thanks to [Andy Hayden](https://github.com/hayd) for maintaining and setting up
these images.
