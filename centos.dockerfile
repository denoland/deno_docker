FROM centos:8.1.1911

ENV DENO_VERSION=0.37.0

RUN curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_linux_x64.gz \
         --output deno.gz \
 && gunzip deno.gz \
 && chmod 777 deno \
 && mv deno /bin/deno

RUN groupadd -g 1993 deno \
 && adduser -u 1993 -g deno deno \
 && mkdir /deno-dir/ \
 && chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/


ENTRYPOINT ["deno"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
