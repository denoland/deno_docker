FROM ubuntu:20.04

ENV DENO_VERSION=1.6.2

RUN apt-get -qq update \
 && apt-get upgrade -y -o Dpkg::Options::="--force-confold" \
 && apt-get -qq install -y ca-certificates curl unzip --no-install-recommends \
 && curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip \
         --output deno.zip \
 && unzip deno.zip \
 && rm deno.zip \
 && chmod 755 deno \
 && mv deno /usr/bin/deno \
 && apt-get -qq remove -y ca-certificates curl unzip \
 && apt-get -y -qq autoremove \
 && apt-get -qq clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd --uid 1993 --user-group deno \
 && mkdir /deno-dir/ \
 && chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

COPY ./_entry.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh


ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
