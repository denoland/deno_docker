FROM arm64v8/debian:stable-20191014-slim

ENV DENO_VERSION=1.9.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update \
 && apt-get -qq install -y --no-install-recommends ca-certificates clang curl git ninja-build python unzip

ARG GN_COMMIT=152c5144ceed9592c20f0c8fd55769646077569b

RUN git clone https://gn.googlesource.com/gn /tmp/gn \
 && git -C /tmp/gn checkout ${GN_COMMIT}

RUN cd /tmp/gn \
 && python build/gen.py \
 && ninja -C out \
 && cp -f /tmp/gn/out/gn /usr/local/bin/gn

ENV RUST_VERSION=1.38.0
RUN curl https://sh.rustup.rs -sSf \
  | sh -s -- --default-toolchain ${RUST_VERSION} -y
ENV PATH=/root/.cargo/bin:$PATH

ENV DENO_VERSION=0.30.0

RUN curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_src.tar.gz \
         --output deno.tar.gz \
 && tar -zxf deno.tar.gz \
 && rm deno.tar.gz


RUN cp /usr/local/bin/gn /deno/core/libdeno/buildtools/linux64/gn
RUN rm /deno/third_party/prebuilt/linux64/sccache

ENV DENO_BUILD_MODE=release

WORKDIR /deno/cli
RUN RUST_BACKTRACE=1 DENO_NO_BINARY_DOWNLOAD=1 DENO_BUILD_ARGS='clang_use_chrome_plugins=false treat_warnings_as_errors=false use_sysroot=false clang_base_path="/usr" use_glib=false use_gold=true' DENO_GN_PATH=gn cargo install --locked --root .. --path .


RUN useradd --uid 1993 --user-group deno \
 && mkdir /deno-dir/ \
 && chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/


ENTRYPOINT ["deno", "run", "https://deno.land/std/examples/welcome.ts"]
