ARG DENO_VERSION=2.7.11
ARG BIN_IMAGE=denoland/deno:bin-${DENO_VERSION}


FROM ${BIN_IMAGE} AS bin


FROM buildpack-deps:20.04-curl AS tini

ARG TINI_VERSION=0.19.0
ARG TARGETARCH

RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${TARGETARCH} \
    --output /tini-${TARGETARCH} \
  && curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${TARGETARCH}.sha256sum \
    --output /tini-${TARGETARCH}.sha256sum \
  && cd / && sha256sum -c tini-${TARGETARCH}.sha256sum \
  && mv /tini-${TARGETARCH} /tini \
  && rm /tini-${TARGETARCH}.sha256sum \
  && chmod +x /tini


FROM debian:stable-slim

RUN useradd --uid 1993 --user-group deno \
  && mkdir /deno-dir/ \
  && chown deno:deno /deno-dir/

ENV DENO_USE_CGROUPS=1
ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=bin /deno /usr/bin/deno

COPY --from=tini /tini /tini

LABEL org.opencontainers.image.title="Deno" \
      org.opencontainers.image.description="Deno Docker image (Debian)" \
      org.opencontainers.image.url="https://github.com/denoland/deno_docker" \
      org.opencontainers.image.source="https://github.com/denoland/deno_docker" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${DENO_VERSION}"

COPY ./_entry.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/tini", "--", "docker-entrypoint.sh"]
CMD ["eval", "console.log('Welcome to Deno!')"]
