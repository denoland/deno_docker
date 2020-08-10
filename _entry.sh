#!/bin/sh
set -e

case "$1" in
    bundle | cache | completions | doc | eval | fmt | help | info | link | repl | run | test | types )
    exec deno "$@";;
esac

exec "$@"
