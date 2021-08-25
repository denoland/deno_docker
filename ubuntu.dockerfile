ARG DENO_VERSION=1.13.2
ARG BIN_IMAGE=denoland/deno:bin-${DENO_VERSION}


FROM ${BIN_IMAGE} AS bin


FROM ubuntu:20.04

RUN useradd --uid 1993 --user-group deno \
  && mkdir /deno-dir/ \
  && chown deno:deno /deno-dir/ \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y tini \
  && rm -rf /var/lib/apt/lists/*

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=bin /deno /usr/bin/deno

COPY ./_entry.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--" "docker-entrypoint.sh"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
