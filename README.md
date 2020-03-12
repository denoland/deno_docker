# Deno Docker

Docker files for [deno](https://github.com/denoland/deno).

These are published on Dockerhub at [hayd/deno](https://hub.docker.com/r/hayd/deno).

![ci status](https://github.com/hayd/deno-docker/workflows/Test/badge.svg?branch=master)

_The binary produced for Amazon Linux 1 can be used to run [deno on AWS Lambda](https://github.com/hayd/deno-lambda/)._

---

## Run locally:

To run `main.ts` from your working directory:

```sh
$ docker run -it --init -p 1993:1993 -v $PWD:/app hayd/deno:alpine-0.35.0 --allow-net /app/main.ts
```

Here, `-p 1993:1993` maps port 1993 on the container to 1993 on the host,
`-v $PWD:/app` mounts the host working directory to `/app` on the container, and
`--allow-net /app/main.ts` is passed to deno on the container.

## As a Dockerfile

```Dockerfile
FROM hayd/deno:alpine-0.36.0

EXPOSE 1993  # The port that your application listens to.

WORKDIR /app

# Prefer not to run as root.
USER deno

# Cache the dependencies as a layer (the following two steps are re-run only when deps.ts is modified).
# Ideally fetch deps.ts will download and compile _all_ external files used in main.ts.
COPY deps.ts .
RUN deno fetch deps.ts

# These steps will be re-run upon each file change in your working directory:
ADD . .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno fetch main.ts

CMD ["--allow-net", "main.ts"]
```

and build and run this locally:

```sh
$ docker build -t app . && docker run -it --init -p 1993:1993 app
```

---

See example directory.

Note: Dockerfiles provide a USER `deno` and DENO_DIR is set to `/deno-dir/` (which can be overridden).

_If running multiple deno instances within the same image you can mount this directory as a shared volume._
