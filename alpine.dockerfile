ARG DENO_VERSION=2.7.10
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

FROM gcr.io/distroless/cc@sha256:66d87e170bc2c5e2b8cf853501141c3c55b4e502b8677595c57534df54a68cc5 AS cc


FROM alpine:latest AS patcher

COPY --from=bin /deno /deno
COPY --from=tini /tini /tini
RUN apk add --no-cache patchelf \
  && patchelf --set-rpath /usr/local/lib/glibc /deno \
  && patchelf --set-rpath /usr/local/lib/glibc /tini


FROM alpine:latest

# Inspired by https://github.com/dojyorin/deno_docker_image/blob/master/src/alpine.dockerfile
# glibc libs are placed in an isolated directory to avoid conflicting with
# Alpine's musl-based packages (e.g. node, ffmpeg).
COPY --from=cc --chown=root:root --chmod=755 /lib/*-linux-gnu/* /usr/local/lib/glibc/
COPY --from=cc --chown=root:root --chmod=755 /lib/ld-linux-* /lib/

RUN addgroup --gid 1000 deno \
  && adduser --uid 1000 --disabled-password deno --ingroup deno \
  && mkdir /deno-dir/ \
  && chown deno:deno /deno-dir/ \
  && mkdir /lib64 \
  && ln -s /usr/local/lib/glibc/ld-linux-* /lib64/

ENV DENO_USE_CGROUPS=1
ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=patcher /deno /bin/deno
COPY --from=patcher /tini /tini

LABEL org.opencontainers.image.title="Deno" \
      org.opencontainers.image.description="Deno Docker image (Alpine)" \
      org.opencontainers.image.url="https://github.com/denoland/deno_docker" \
      org.opencontainers.image.source="https://github.com/denoland/deno_docker" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${DENO_VERSION}"

COPY ./_entry.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/tini", "--", "docker-entrypoint.sh"]
CMD ["eval", "console.log('Welcome to Deno!')"]
