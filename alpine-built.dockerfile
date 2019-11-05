# WARNING: This is not working yet...


# STEP 1
# Build GN for alpine.
#
FROM alpine:3.10.1 as gn-builder

# There are many like but this one is ours...
ARG GN_COMMIT=152c5144ceed9592c20f0c8fd55769646077569b

# Note: This probably makes builds not reprodible but is necessary for recent llvm (9 vs 4).
RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories
RUN apk upgrade --update-cache --available

RUN \
  apk add --update --virtual .gn-build-dependencies \
    alpine-sdk \
    binutils-gold \
    clang \
    curl \
    git \
    llvm \
    ninja \
    python \
    tar \
    xz \
  # Two quick fixes: we need the LLVM tooling in $PATH, and we
  # also have to use gold instead of ld.
  && PATH=$PATH:/usr/lib/llvm9/bin \
  && cp -f /usr/bin/ld.gold /usr/bin/ld \
  # Clone and build gn
  && git clone https://gn.googlesource.com/gn /tmp/gn \
  && git -C /tmp/gn checkout ${GN_COMMIT} \
  && cd /tmp/gn \
  && python build/gen.py \
  && ninja -C out \
  && cp -f /tmp/gn/out/gn /usr/local/bin/gn \
  # Remove build dependencies and temporary files
  && apk del .gn-build-dependencies \
&& rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

# STEP 2
# Build deno binary for alpine.
#
FROM alpine:3.10.1 as deno-builder

ENV DENO_BUILD_MODE=release
ENV DENO_VERSION=0.23.0

RUN apk add --no-cache curl && \
    curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_src.tar.gz --output deno.tar.gz && \
    tar -zxf deno.tar.gz && \
    rm deno.tar.gz && \
    apk del curl

# we need a very recent version of rust et al only available in edge repo.
RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories
RUN apk upgrade --update-cache --available
RUN apk add rust cargo clang bash python ninja linux-headers alpine-sdk build-base binutils-gold llvm linux-headers lld

COPY --from=gn-builder /usr/local/bin/gn /bin/gn
RUN cp /bin/gn /deno/third_party/v8/buildtools/linux64/gn

RUN cp /usr/bin/ninja /deno/third_party/depot_tools/ninja-linux64

RUN apk add --no-cache xz
RUN curl -fL http://releases.llvm.org/9.0.0/clang+llvm-9.0.0-x86_64-linux-sles11.3.tar.xz \
         --output /tmp/clang.tar.xz \
 && tar xf /tmp/clang.tar.xz -C /tmp \
 && rm /tmp/clang.tar.xz \
 && mv /tmp/clang+llvm-9.0.0-x86_64-linux-sles11.3 /tmp/clang-llvm
ENV PATH=/tmp/clang-llvm/bin:$PATH

WORKDIR deno/cli
RUN RUST_BACKTRACE=1 DENO_NO_BINARY_DOWNLOAD=1 DENO_BUILD_ARGS='clang_use_chrome_plugins=false treat_warnings_as_errors=false use_sysroot=false clang_base_path="/tmp/clang-llvm" use_glib=false use_gold=true' DENO_GN_PATH=gn cargo install --locked --root .. --path . || echo error

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
