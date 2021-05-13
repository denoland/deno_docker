FROM ekidd/rust-musl-builder:1.40.0

RUN sudo apt-get -qq -y update && sudo apt-get install -y python unzip

ENV NINJA_VERSION=1.8.2
RUN curl -fsSL https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip \
         --output ninja.zip \
 && unzip ninja.zip \
 && sudo mv ninja /bin/ninja \
 && rm ninja.zip

# FIXME specify a version of gn here rather than "latest"
ENV GN_VERSION=latest
RUN curl -fL https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-amd64/+/${GN_VERSION} \
         --output gn.zip \
 && unzip gn.zip gn \
 && sudo mv gn /bin/gn \
 && rm gn.zip

ENV DENO_VERSION=1.9.0

RUN curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_src.tar.gz \
         --output deno.tar.gz \
 && tar -zxf deno.tar.gz \
 && rm deno.tar.gz

# recent clang
RUN curl -s https://raw.githubusercontent.com/chromium/chromium/master/tools/clang/scripts/update.py | python - --output-dir=/tmp/clang

ENV DENO_BUILD_MODE=release
ENV CLANG_BASE_PATH=/tmp/clang
ENV GN=/bin/gn
ENV NINJA=/bin/ninja
ENV RUST_BACKTRACE=full
ENV GN_ARGS='clang_use_chrome_plugins=false treat_warnings_as_errors=false use_sysroot=false use_glib=false use_gold=true clang_base_path="/tmp/clang"'

WORKDIR /home/rust/src/deno/cli

RUN cargo install --locked --root .. --path . --force || echo failed
RUN cargo build --package rusty_v8 || echo failed
RUN cargo install --locked --root .. --path . --force || echo failed


WORKDIR /tmp
RUN mkdir /tmp/lib
ADD lib .
WORKDIR /home/rust/src/deno/cli


ENTRYPOINT ["bash"]
