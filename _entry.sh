#!/bin/sh
set -e

case "$1" in
    bundle | cache | compile | completions | coverage | doc | eval | fmt | help | info | install | lint | lsp | repl | run | test | types | upgrade )
    exec deno "$@";;
esac

exec "$@"
