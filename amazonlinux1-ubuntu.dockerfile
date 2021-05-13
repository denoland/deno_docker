FROM  phusion/baseimage:0.11

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq -y update \
 && apt-get install -qq -y build-essential curl libxml2 lld llvm musl musl-tools python unzip

ENV NINJA_VERSION=1.8.2
RUN curl -fsSL https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip \
         --output ninja.zip \
 && unzip ninja.zip \
 && mv ninja /bin/ninja \
 && rm ninja.zip

# FIXME specify a version of gn here rather than "latest"
ENV GN_VERSION=latest
RUN curl -fL https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-amd64/+/${GN_VERSION} \
         --output gn.zip \
 && unzip gn.zip gn \
 && mv gn /bin/gn \
 && rm gn.zip

ENV RUST_VERSION=1.40.0
RUN curl https://sh.rustup.rs -sSf \
  | sh -s -- --default-toolchain ${RUST_VERSION} -y
ENV PATH=/root/.cargo/bin:$PATH
RUN rustup target add x86_64-unknown-linux-musl

ENV DENO_VERSION=1.9.0

RUN curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_src.tar.gz \
         --output deno.tar.gz \
 && tar -zxf deno.tar.gz \
 && rm deno.tar.gz

#RUN yum install -y gcc-c++ libatomic
#RUN echo "INPUT ( /usr/lib64/libatomic.so.1.2.0 )" \
#  > "/usr/lib/gcc/x86_64-amazon-linux/4.8.5/libatomic.so"

ENV DENO_BUILD_MODE=release
#ENV CLANG_BASE_PATH=/tmp/clang-llvm
ENV GN=/bin/gn
ENV NINJA=/bin/ninja

WORKDIR ./cli

RUN curl -s https://raw.githubusercontent.com/chromium/chromium/master/tools/clang/scripts/update.py | python - --output-dir=/tmp/clang

RUN RUSTFLAGS="-C linker=musl-gcc" CC_x86_64_unknown_linux_musl="x86_64-linux-musl-gcc" RUST_BACKTRACE=full GN_ARGS='clang_use_chrome_plugins=false treat_warnings_as_errors=false use_sysroot=false clang_base_path="/tmp/clang" use_glib=false use_gold=true' cargo install --target x86_64-unknown-linux-musl --locked --root .. --path . --force || echo failed

## RUN RUST_BACKTRACE=full GN_ARGS='clang_use_chrome_plugins=false treat_warnings_as_errors=false use_sysroot=false clang_base_path="/tmp/clang" use_glib=false use_gold=true' cargo install --locked --target x86_64-unknown-linux-musl --root .. --path .

ENTRYPOINT ["bash"]

# Confirm the binary works on a fresh image.
#FROM amazonlinux:2017.03.1.20170812

#COPY --from=0 /deno/target/release/deno /bin/deno
#ENV DENO_DIR /deno-dir/


#ENTRYPOINT ["deno", "run", "https://deno.land/std/examples/welcome.ts"]
