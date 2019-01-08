FROM frolvlad/alpine-glibc:alpine-3.8

ENV DENO_VERSION=0.2.6

RUN apk add --no-cache curl && \
    curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_linux_x64.gz --output deno.gz && \
    gunzip deno.gz && \
    chmod 777 deno && \
    mv deno /bin/deno && \
    apk del curl

ENTRYPOINT ["deno", "https://deno.land/thumb.ts"]

