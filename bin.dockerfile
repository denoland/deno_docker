ARG DENO_VERSION=2.1.0


FROM buildpack-deps:20.04-curl AS download

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y unzip \
  && rm -rf /var/lib/apt/lists/*

ARG DENO_VERSION
ARG TARGETARCH

RUN curl -fsSL https://dl.deno.land/release/v${DENO_VERSION}/deno-$(echo $TARGETARCH | sed -e 's/arm64/aarch64/' -e 's/amd64/x86_64/')-unknown-linux-gnu.zip \
    --output deno.zip \
  && unzip deno.zip \
  && rm deno.zip \
  && chmod 755 deno


FROM scratch

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}

COPY --from=download /deno /deno
