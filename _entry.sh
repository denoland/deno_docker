#!/bin/sh
set -e

if [ "$1" != "${1#-}" ]; then
    # if the first argument is an option like `--help` or `-h`
    exec deno "$@"
fi

case "$1" in
    add | bench | bundle | cache | compile | completions | coverage | doc | eval | fmt | help | init | info | install | jupyter | lint | lsp | publish | remove | repl | run | serve | task | test | types | uninstall | upgrade | vendor )
    # if the first argument is a known deno command
    exec deno "$@";;
esac

exec "$@"
