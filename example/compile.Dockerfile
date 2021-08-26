FROM hayd/deno:1.9.2 AS build

WORKDIR /app

COPY deps.ts .
RUN deno cache deps.ts

COPY . .
RUN deno compile --allow-net --unstable --lite --output /usr/local/bin/app main.ts


FROM gcr.io/distroless/cc:latest

COPY --from=build /usr/local/bin/app /usr/local/bin/app

CMD ["/usr/local/bin/app"]
