FROM hayd/deno-lambda:1.6.1

COPY hello.ts .
RUN deno cache hello.ts


CMD ["hello.handler"]
