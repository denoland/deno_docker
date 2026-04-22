ARG DENO_VERSION=2.7.13
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


FROM gcr.io/distroless/cc

ENV DENO_USE_CGROUPS=1
ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=bin /deno /bin/deno

COPY --from=tini /tini /tini

LABEL org.opencontainers.image.title="Deno" \
      org.opencontainers.image.description="Deno Docker image (Distroless)" \
      org.opencontainers.image.url="https://github.com/denoland/deno_docker" \
      org.opencontainers.image.source="https://github.com/denoland/deno_docker" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${DENO_VERSION}"

ENTRYPOINT ["/tini", "--", "/bin/deno"]
CMD ["eval", "console.log('Welcome to Deno!')"]
