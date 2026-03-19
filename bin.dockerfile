ARG DENO_VERSION=2.7.6


FROM buildpack-deps:20.04-curl AS download

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y unzip \
  && rm -rf /var/lib/apt/lists/*

ARG DENO_VERSION
ARG TARGETARCH

RUN export DENO_TARGET=$(echo $TARGETARCH | sed -e 's/arm64/aarch64/' -e 's/amd64/x86_64/') \
  && curl -fsSL https://dl.deno.land/release/v${DENO_VERSION}/deno-${DENO_TARGET}-unknown-linux-gnu.zip \
    --output deno.zip \
  && curl -fsSL https://dl.deno.land/release/v${DENO_VERSION}/deno-${DENO_TARGET}-unknown-linux-gnu.zip.sha256sum \
    --output deno.zip.sha256sum \
  && sha256sum -c deno.zip.sha256sum \
  && unzip deno.zip \
  && rm deno.zip deno.zip.sha256sum \
  && chmod 755 deno


FROM scratch

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}

COPY --from=download /deno /deno
