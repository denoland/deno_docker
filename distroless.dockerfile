ARG DENO_VERSION=2.0.0-rc.4
ARG BIN_IMAGE=denoland/deno:bin-${DENO_VERSION}


FROM ${BIN_IMAGE} AS bin


FROM buildpack-deps:20.04-curl AS tini

ARG TINI_VERSION=0.19.0
ARG TARGETARCH

RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${TARGETARCH} \
    --output /tini \
  && chmod +x /tini


FROM gcr.io/distroless/cc


ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=bin /deno /bin/deno

COPY --from=tini /tini /tini

ENTRYPOINT ["/tini", "--", "/bin/deno"]
CMD ["eval", "console.log('Welcome to Deno!')"]
