FROM public.ecr.aws/lambda/provided:al2

ENV BOOTSTRAP_VERSION=1.6.0
ENV DENO_VERSION=1.6.1

ENV DENO_DIR=/tmp/deno_dir
ENV DENO_INSTALL_ROOT=/usr/local

RUN yum install -q -y unzip \
 && curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip \
         --output deno.zip \
 && unzip -qq deno.zip \
 && rm deno.zip \
 && chmod 777 deno \
 && mv deno /bin/deno \
 && curl -fsSL https://deno.land/x/lambda@${BOOTSTRAP_VERSION}/bootstrap \
         --out ${LAMBDA_RUNTIME_DIR}/bootstrap \
 && chmod 777 ${LAMBDA_RUNTIME_DIR}/bootstrap \
 && yum remove -q -y unzip \
 && rm -rf /var/cache/yum
