FROM debian:stretch-slim

ENV DENO_VERSION=0.2.5
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends curl ca-certificates && \
    curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_linux_x64.gz --output deno.gz && \
    gunzip deno.gz && \
    chmod 777 deno && \
    mv deno /usr/bin/deno && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["deno", "https://deno.land/thumb.ts"]

