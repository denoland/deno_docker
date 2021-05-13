FROM hayd/ubuntu-deno:1.6.2

WORKDIR /app
ADD z.ts .
RUN chmod 755 z.ts

ENTRYPOINT ["/app/z.ts"]

