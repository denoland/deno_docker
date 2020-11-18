FROM amazonlinux:2.0.20200722.0
# We build deno for the Amazon Linux 2 AMI/image used by AWS Lambda.

RUN yum install -y curl unzip

ENV NINJA_VERSION=1.8.2
RUN curl -fsSL https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip \
  --output ninja.zip \
  && unzip ninja.zip \
  && mv ninja /bin/ninja \
  && rm ninja.zip

# FIXME specify a version of gn here rather than "latest"
# actually this is a instance_id? see:
# https://chrome-infra-packages.appspot.com/p/gn/gn/linux-amd64/+/
ENV GN_VERSION=p5bsB7KHKpHTRMZFMTcIddhGcBcYZiH8m4g4Q_T9MOkC
RUN curl -fL https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-amd64/+/${GN_VERSION} \
  --output gn.zip \
  && unzip gn.zip gn \
  && mv gn /bin/gn \
  && rm gn.zip

RUN yum install -y xz tar gzip
RUN curl -fL https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.0/clang+llvm-10.0.0-x86_64-linux-sles11.3.tar.xz \
  --output /tmp/clang.tar.xz \
  && tar xf /tmp/clang.tar.xz -C /tmp \
  && rm /tmp/clang.tar.xz \
  && mv /tmp/clang+llvm-10.0.0-x86_64-linux-sles11.3 /tmp/clang
ENV PATH=/tmp/clang-llvm/bin:$PATH

ENV RUST_VERSION=1.47.0
RUN curl https://sh.rustup.rs -sSf \
  | sh -s -- --default-toolchain ${RUST_VERSION} -y
ENV PATH=/root/.cargo/bin:$PATH

RUN yum install -y gcc-c++ libatomic
RUN echo "INPUT ( /usr/lib64/7/libatomic.so )" \
  > "/usr/lib/gcc/x86_64-redhat-linux/7/libatomic.so"

ENV DENO_VERSION=1.5.3

RUN curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_src.tar.gz \
  --output deno.tar.gz \
  && tar -zxf deno.tar.gz \
  && rm deno.tar.gz

ENV DENO_BUILD_MODE=release
ENV CLANG_BASE_PATH=/tmp/clang
ENV GN=/bin/gn
ENV NINJA=/bin/ninja
ENV RUST_BACKTRACE=full
ENV GN_ARGS=' \
  clang_use_chrome_plugins=false \
  treat_warnings_as_errors=false \
  use_sysroot=false \
  clang_base_path="/tmp/clang" \
  use_glib=false \
  use_gold=true \
  '

WORKDIR /deno/cli
RUN cargo install --locked --root .. --path .

# Confirm the binary works on a fresh image.
FROM amazonlinux:2.0.20200722.0

COPY --from=0 /deno/target/release/deno /bin/deno
ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

COPY ./_entry.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
