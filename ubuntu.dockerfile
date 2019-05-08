FROM phusion/baseimage:0.11

ENV DENO_VERSION=0.4.0

RUN apt-get -qq install -y curl && \
    curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_linux_x64.gz --output deno.gz && \
    gunzip deno.gz && \
    chmod 777 deno && \
    mv deno /usr/bin/deno && \
    apt-get -qq remove -y curl && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["deno", "run", "https://deno.land/thumb.ts"]

