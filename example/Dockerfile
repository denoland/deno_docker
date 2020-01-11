FROM hayd/deno:alpine-0.29.0

EXPOSE 1993

WORKDIR /app

USER deno

COPY deps.ts .
RUN deno fetch deps.ts

ADD . .
RUN deno fetch main.ts

ENTRYPOINT ["deno", "run", "--allow-net", "main.ts"]
