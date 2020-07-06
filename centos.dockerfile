FROM centos:8.1.1911

ENV DENO_VERSION=1.1.3

RUN yum makecache \
 && yum install unzip -y \
 && curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip \
         --output deno.zip \
 && unzip deno.zip \
 && rm deno.zip \
 && chmod 777 deno \
 && mv deno /bin/deno \
 && yum remove unzip -y \
 && yum clean all \
 && rm -rf /var/cache/yum

RUN groupadd -g 1993 deno \
 && adduser -u 1993 -g deno deno \
 && mkdir /deno-dir/ \
 && chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/


ENTRYPOINT ["deno"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
