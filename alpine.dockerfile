ARG DENO_VERSION=1.13.2
ARG BIN_IMAGE=denoland/deno:bin-${DENO_VERSION}


FROM ${BIN_IMAGE} AS bin


FROM buildpack-deps:20.04-curl AS tini

ARG TINI_VERSION=0.19.0
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini \
    --output /tini \
  && chmod +x /tini


FROM frolvlad/alpine-glibc:alpine-3.13

RUN addgroup --gid 1000 deno \
  && adduser --uid 1000 --disabled-password deno --ingroup deno \
  && mkdir /deno-dir/ \
  && chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=bin /deno /bin/deno

COPY --from=tini /tini /tini

COPY ./_entry.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/tini", "--", "docker-entrypoint.sh"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
