ARG DENO_VERSION=1.13.2


FROM alpine:3 AS download

RUN apk add --no-cache curl unzip

ARG DENO_VERSION
RUN curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip \
    --output deno.zip \
  && unzip deno.zip \
  && rm deno.zip \
  && chmod 755 deno


FROM scratch

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}

COPY --from=download /deno /deno
