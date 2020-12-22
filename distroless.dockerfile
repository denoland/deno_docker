FROM alpine:3.12.3

ENV DENO_VERSION=1.6.2

RUN apk add --virtual .download --no-cache curl \
 && curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip \
         --output deno.zip \
 && unzip deno.zip \
 && rm deno.zip \
 && chmod 755 deno \
 && mv deno /bin/deno \
 && apk del .download


FROM gcr.io/distroless/cc
COPY --from=0 /bin/deno /bin/deno

ENV DENO_VERSION=1.6.2
ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local


ENTRYPOINT ["/bin/deno"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]

