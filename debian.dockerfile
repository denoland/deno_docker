ARG DENO_VERSION=1.13.2
ARG BIN_IMAGE=denoland/deno:bin-${DENO_VERSION}


FROM ${BIN_IMAGE} AS bin


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

COPY ./_entry.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
