FROM balenalib/rpi-raspbian:buster-20191014

ENV DEBIAN_FRONTEND=noninteractive

ARG GN_COMMIT=152c5144ceed9592c20f0c8fd55769646077569b

RUN apt-get -qq update \
 && apt-get -qq install -y --no-install-recommends \
      clang git llvm ninja-build

RUN git clone https://gn.googlesource.com/gn /tmp/gn \
  && git -C /tmp/gn checkout ${GN_COMMIT} \
  && cd /tmp/gn \
  && python build/gen.py \
  && ninja -C out 
#  && cp -f /tmp/gn/out/gn /usr/local/bin/gn \
  # Remove build dependencies and temporary files
#  && apk del .gn-build-dependencies \
#&& rm -rf /tmp/* /var/tmp/* /var/cache/apk/*


ENV DENO_VERSION=1.9.0


ENTRYPOINT ["bash"]
