FROM frolvlad/alpine-glibc:alpine-3.10_glibc-2.29

RUN apk add libstdc++

ENTRYPOINT ["sh"]