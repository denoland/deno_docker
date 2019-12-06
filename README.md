# Deno Docker

Docker files for [deno](https://github.com/denoland/deno).

These are published on Dockerhub at [hayd/deno](https://hub.docker.com/r/hayd/deno).

![ci status](https://github.com/hayd/deno-docker/workflows/Test/badge.svg?branch=master)

_The binary produced for Amazon Linux 1 can be used to run [deno on AWS Lambda](https://github.com/hayd/deno-lambda/)._

---

For example:

```Dockerfile
FROM hayd/deno:alpine-0.26.0

EXPOSE 1993

WORKDIR /app

# Prefer not to run as root.
USER deno

# Cache the dependencies as a layer (this is re-run only when deps.ts is modified).
# Ideally this will download and compile _all_ external files used in main.ts.
COPY deps.ts /app
RUN deno fetch deps.ts

# These steps will be re-run upon each file change in your working directory:
ADD . /app
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno fetch main.ts

ENTRYPOINT ["deno", "run", "--allow-net", "main.ts"]
```

and run locally:

```sh
$ docker build -t app . && docker run -it --init -p 1993:1993 app
```

See example directory.

Note: Dockerfiles provide a USER `deno` and DENO_DIR is set to `/deno-dir/` (which can be overridden).

_If running multiple deno instances within the same image you can mount this directory as a shared volume._
