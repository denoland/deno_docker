# Deno Docker

Docker files for [deno](https://github.com/denoland/deno) published on Dockerhub:

- Alpine Linux: [hayd/alpine-deno](https://hub.docker.com/r/hayd/alpine-deno/) (\~28Mb)
- Centos: [hayd/centos-deno](https://hub.docker.com/r/hayd/centos-deno/) (\~94Mb)
- Debian: [hayd/debian-deno](https://hub.docker.com/r/hayd/debian-deno/) (\~47Mb)
- Distroless: [hayd/distroless-deno](https://hub.docker.com/r/hayd/distroless-deno) (\~28Mb)
- Ubuntu: [hayd/ubuntu-deno](https://hub.docker.com/r/hayd/ubuntu-deno/) (\~50Mb)

![ci status](https://github.com/hayd/deno-docker/workflows/Test/badge.svg?branch=master)

_To run [deno containers on AWS Lambda](https://hub.docker.com/r/hayd/deno-lambda/), see lambda/,
and the [deno-lambda](https://github.com/hayd/deno-lambda) project._

---

## Run locally

To start the `deno` repl:

```sh
$ docker run -it --init hayd/alpine-deno:1.6.2 repl
```

To shell into the docker runtime:

```sh
$ docker run -it --init --entrypoint sh hayd/alpine-deno:1.6.2
```

To run `main.ts` from your working directory:

```sh
$ docker run -it --init -p 1993:1993 -v $PWD:/app hayd/alpine-deno:1.6.2 run --allow-net /app/main.ts
```

Here, `-p 1993:1993` maps port 1993 on the container to 1993 on the host,
`-v $PWD:/app` mounts the host working directory to `/app` on the container, and
`--allow-net /app/main.ts` is passed to deno on the container.

## As a Dockerfile

```Dockerfile
FROM hayd/alpine-deno:1.6.2

# The port that your application listens to.
EXPOSE 1993

WORKDIR /app

# Cache the dependencies as a layer (the following two steps are re-run only when deps.ts is modified).
# Ideally cache deps.ts will download and compile _all_ external files used in main.ts.
COPY deps.ts .
RUN deno cache deps.ts

# These steps will be re-run upon each file change in your working directory:
ADD . .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

# Prefer not to run as root.
USER deno

CMD ["run", "--allow-net", "main.ts"]
```

and build and run this locally:

```sh
$ docker build -t app . && docker run -it --init -p 1993:1993 app
```

## (optional) Add `deno` alias to your shell

Alternatively, you can add `deno` command to your shell init file (e.g. `.bashrc`):

```sh
deno () {
  docker run \
    --interactive \
    --tty \
    --rm \
    --volume $PWD:/app \
    --volume $HOME/.deno:/deno-dir \
    --workdir /app \
    hayd/alpine-deno:1.6.2 \
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

Note: Dockerfiles provide a USER `deno` and DENO_DIR is set to `/deno-dir/` (which can be overridden).

_If running multiple deno instances within the same image you can mount this directory as a shared volume._
