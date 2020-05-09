FROM hayd/alpine-deno:1.0.0-rc1rc1

EXPOSE 1993

WORKDIR /app

USER deno

COPY deps.ts .
RUN deno cache deps.ts

ADD . .
RUN deno cache main.ts

CMD ["run", "--allow-net", "main.ts"]
