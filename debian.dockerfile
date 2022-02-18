ARG DENO_VERSION=1.19.0
ARG BIN_IMAGE=denoland/deno:bin-${DENO_VERSION}


FROM ${BIN_IMAGE} AS bin


FROM buildpack-deps:20.04-curl AS tini

ARG TINI_VERSION=0.19.0
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini \
    --output /tini \
  && chmod +x /tini


FROM debian:stable-slim

ENV DENO_DIR=/deno-dir/
ENV DENO_INSTALL_ROOT=/opt/deno/
ENV PATH="${DENO_INSTALL_ROOT}/bin:${PATH}"

RUN useradd --uid 1993 --user-group deno \
  && mkdir "${DENO_DIR}" \
  && chown deno:deno "${DENO_DIR}" \
  && mkdir -p "${DENO_INSTALL_ROOT}" \
  && chown deno:deno "${DENO_INSTALL_ROOT}"

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=bin --chown=deno:deno /deno "${DENO_INSTALL_ROOT}/bin/deno"

COPY --from=tini /tini /tini

COPY ./_entry.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/tini", "--", "docker-entrypoint.sh"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
