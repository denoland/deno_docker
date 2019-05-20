FROM hayd/deno:alpine-0.6.0

EXPOSE 1993

WORKDIR /app
ADD . /app

ENTRYPOINT ["deno", "run", "--allow-net", "main.ts"]
