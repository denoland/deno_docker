FROM hayd/deno:alpine-0.6.0

EXPOSE 1993

WORKDIR /app
ENV DENO_DIR /cache/

COPY deps.ts /app
RUN deno fetch deps.ts
ADD . /app
RUN deno fetch main.ts

ENTRYPOINT ["deno", "run", "--allow-net", "main.ts"]
