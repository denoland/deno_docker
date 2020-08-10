FROM frolvlad/alpine-glibc:alpine-3.11_glibc-2.31

ENV DENO_VERSION=1.2.2

RUN apk add --virtual .download --no-cache curl \
        && curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip \
        --output deno.zip \
        && unzip deno.zip \
        && rm deno.zip \
        && chmod 777 deno \
        && mv deno /bin/deno \
        && apk del .download

RUN addgroup -g 1993 -S deno \
        && adduser -u 1993 -S deno -G deno \
        && mkdir /deno-dir/ \
        && chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

COPY ./_entry.sh /.docker-entry.sh
RUN chmod 777 /.docker-entry.sh


ENTRYPOINT ["/.docker-entry.sh"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
