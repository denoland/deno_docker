FROM frolvlad/alpine-glibc:alpine-3.10_glibc-2.29

ENV DENO_VERSION=0.24.0

RUN apk add --no-cache curl \
 && curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_linux_x64.gz \
         --output deno.gz \
 && gunzip deno.gz \
 && chmod 777 deno \
 && mv deno /bin/deno \
 && apk del curl

RUN addgroup -g 1993 -S deno \
 && adduser -u 1993 -S deno -G deno \
 && mkdir /deno-dir/ \
 && chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/


ENTRYPOINT ["deno", "run", "https://deno.land/std/examples/welcome.ts"]
