#FROM arm64v8/debian:stable-slim

FROM arm64v8/rust:slim

RUN cargo install deno || echo 'error'

