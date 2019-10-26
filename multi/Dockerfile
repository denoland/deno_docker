# STEP 1
# Build GN for alpine
#
FROM alpine:3.10.1 as gn-builder

# This is the GN commit that we want to build.
# Most commits will probably build just fine but
# this happened to be the latest commit when I did this.
# There are many like but this one is ours...
ARG GN_COMMIT=d7111cb6877187d1f378bd231e14ffdd5fdd87ae

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
  && python build/gen.py --no-sysroot \
  && ninja -C out \
  && cp -f /tmp/gn/out/gn /usr/local/bin/gn \
  # Remove build dependencies and temporary files
  && apk del .gn-build-dependencies \
&& rm -rf /tmp/* /var/tmp/* /var/cache/apk/*


# STEP 2
# Build deno binary
#
FROM alpine:3.10.1 as build-deno

# COPY --from=source /tmp/v8 /tmp/v8

# Note(hayd): We had to add `at-spi2-core-dev`.

RUN \
  apk add --update --virtual .v8-build-dependencies \
    at-spi2-core-dev \
    curl \
    g++ \
    gcc \
    glib-dev \
    icu-dev \
    libstdc++ \
    linux-headers \
    make \
    ninja \
    python \
    tar \
    xz

ENV DENO_BUILD_MODE release

RUN \
  apk add git && \
  git clone https://github.com/denoland/deno.git && \
  cd deno && \
  git checkout v0.21.0 && \
  git submodule update --init --recursive

RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories
RUN apk upgrade --update-cache --available
RUN apk add rust cargo clang bash

COPY --from=gn-builder /usr/local/bin/gn /bin/gn
RUN cp /bin/gn /deno/third_party/v8/buildtools/linux64/gn

# None of the following work!

# RUN cd deno && gn gen --args='clang_base_path="/usr/bin/" is_debug=false is_official_build=true symbol_level=0 use_sysroot=false' target/release
# RUN system "ninja", "-j", ENV.make_jobs, "-C", "target/release", "-v", "deno"
# RUN ls "target/release/deno"

# cd deno/cli

# RUN DENO_NO_BINARY_DOWNLOAD=1 DENO_BUILD_ARGS='clang_use_chrome_plugins=false treat_warnings_as_errors=false use_sysroot=false clang_base_path="/usr"' DENO_GN_PATH=gn cargo install -vv --root .. --path .

# RUST_BACKTRACE=1 DENO_NO_BINARY_DOWNLOAD=1 DENO_BUILD_ARGS='clang_use_chrome_plugins=false treat_warnings_as_errors=false use_sysroot=false clang_base_path="/usr" use_glib=false' DENO_GN_PATH=gn cargo install --root .. --path .

ENTRYPOINT ["sh"]

# Step 3
# clean alpine with the deno binary available
#
# TODO
