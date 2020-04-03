FROM hayd/alpine-deno:0.39.0

EXPOSE 1993

WORKDIR /app

USER deno

COPY deps.ts .
RUN deno fetch deps.ts

ADD . .
RUN deno fetch main.ts

CMD ["run", "--allow-net", "main.ts"]
