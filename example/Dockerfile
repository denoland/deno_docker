FROM hayd/deno:alpine-0.3.4

EXPOSE 1993

WORKDIR /app
ADD . /app

ENTRYPOINT ["deno", "--allow-net", "main.ts"]
