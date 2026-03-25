ARG DENO_VERSION=2.7.7


FROM buildpack-deps:20.04-curl AS download

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y unzip \
  && rm -rf /var/lib/apt/lists/*

ARG DENO_VERSION
ARG TARGETARCH

RUN export DENO_TARGET=$(echo $TARGETARCH | sed -e 's/arm64/aarch64/' -e 's/amd64/x86_64/') \
  && export DENO_ZIP=deno-${DENO_TARGET}-unknown-linux-gnu.zip \
  && curl -fsSL https://dl.deno.land/release/v${DENO_VERSION}/${DENO_ZIP} \
    --output ${DENO_ZIP} \
  && curl -fsSL https://dl.deno.land/release/v${DENO_VERSION}/${DENO_ZIP}.sha256sum \
    --output ${DENO_ZIP}.sha256sum \
  && sha256sum -c ${DENO_ZIP}.sha256sum \
  && unzip ${DENO_ZIP} \
  && rm ${DENO_ZIP} ${DENO_ZIP}.sha256sum \
  && chmod 755 deno


FROM scratch

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}

LABEL org.opencontainers.image.title="Deno" \
      org.opencontainers.image.description="Deno binary image" \
      org.opencontainers.image.url="https://github.com/denoland/deno_docker" \
      org.opencontainers.image.source="https://github.com/denoland/deno_docker" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${DENO_VERSION}"

COPY --from=download /deno /deno
