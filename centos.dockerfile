ARG DENO_VERSION=1.41.1
ARG BIN_IMAGE=denoland/deno:bin-${DENO_VERSION}


FROM ${BIN_IMAGE} AS bin


FROM buildpack-deps:20.04-curl AS tini

ARG TINI_VERSION=0.19.0
ARG TARGETARCH

RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${TARGETARCH} \
    --output /tini \
  && chmod +x /tini

FROM gcr.io/distroless/cc as cc

FROM centos:8

RUN groupadd -g 1993 deno \
  && adduser -u 1993 -g deno deno \
  && mkdir /deno-dir/ \
  && chown deno:deno /deno-dir/

# CentOS image is EOL, so we need to bump the libm version from distroless. This is a bit
# of a hack.
RUN rm /lib64/libm*
COPY --from=cc --chown=root:root --chmod=755 /lib/*/libm* /lib64/

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=bin /deno /bin/deno

COPY --from=tini /tini /tini

COPY ./_entry.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/tini", "--", "docker-entrypoint.sh"]
CMD ["eval", "console.log('Welcome to Deno!')"]
