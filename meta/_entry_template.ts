export const template = `
#!/bin/sh
set -e

case "$1" in
    DENO_SUBCOMMANDS_SEPARATED_BY_PIPES )
    exec deno "$@";;
esac

exec "$@"
`.trim();
