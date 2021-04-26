# WARNING: This is not working yet...

# STEP 2
# Build deno binary for alpine.
#
FROM alpine as deno-builder

ENV DENO_BUILD_MODE=release
ENV DENO_VERSION=1.9.2

RUN apk add --no-cache curl && \
  curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_src.tar.gz --output deno.tar.gz && \
  tar -zxf deno.tar.gz && \
  rm deno.tar.gz && \
  apk del curl

RUN apk add gn --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

# we need a very recent version of rust et al only available in edge repo.
RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories
RUN apk upgrade --update-cache --available
RUN apk add rust cargo clang bash python2 ninja linux-headers alpine-sdk build-base binutils-gold llvm linux-headers lld

# COPY --from=gn-builder /usr/local/bin/gn /bin/gn

ENV GN=/usr/bin/gn
ENV NINJA=/usr/bin/ninja

RUN apk add --no-cache xz
RUN curl -fL https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang+llvm-11.0.0-x86_64-linux-sles12.4.tar.xz \
  --output /tmp/clang.tar.xz \
  && tar xf /tmp/clang.tar.xz -C /tmp \
  && rm /tmp/clang.tar.xz \
  && mv /tmp/clang+llvm-11.0.0-x86_64-linux-sles12.4 /tmp/clang-llvm
ENV PATH=/tmp/clang-llvm/bin:$PATH

WORKDIR deno/cli

RUN V8_FROM_SOURCE=1 RUST_BACKTRACE=1 CLANG_BASE_PATH=/tmp/clang-llvm GN_ARGS='clang_use_chrome_plugins=false treat_warnings_as_errors=false use_sysroot=false clang_base_path="/tmp/clang-llvm" use_glib=false use_gold=true' cargo install -vv --locked --root .. --path . || echo error
RUN apk add --no-cache python3
RUN V8_FROM_SOURCE=1 RUST_BACKTRACE=1 CLANG_BASE_PATH=/tmp/clang-llvm GN_ARGS='clang_use_chrome_plugins=false treat_warnings_as_errors=false use_sysroot=false clang_base_path="/tmp/clang-llvm" use_glib=false use_gold=true' cargo install -vv --locked --root .. --path . || echo error


ENTRYPOINT ["sh"]

# STEP 3
# Include deno binary in a fresh alpine.
#
# TODO
# COPY --from=deno-builder /deno/target/release/deno /bin/deno
# are permissions preserved? does this need to be made executable?
#
# RUN addgroup -g 1993 -S deno && \
#     adduser -u 1993 -S deno -G deno && \
#     mkdir /deno-dir/ && \
#     chown deno:deno /deno-dir/
# ENV DENO_DIR /deno-dir/
#
# ENTRYPOINT ["deno", "run", "https://deno.land/std/examples/welcome.ts"]
