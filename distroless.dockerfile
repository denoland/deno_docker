ARG DENO_VERSION=1.13.2
ARG BIN_IMAGE=denoland/deno:bin-${DENO_VERSION}


FROM ${BIN_IMAGE} AS bin


FROM gcr.io/distroless/cc

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=bin /deno /bin/deno

ENTRYPOINT ["/bin/deno"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
