import { serve } from "https://deno.land/std/net/http.ts";

const PORT = 1993;
const s = serve(`0.0.0.0:${PORT}`);

async function main() {
  console.log(`Server started on port ${PORT}`);
  for await (const req of s) {
    req.respond({ body: new TextEncoder().encode("Hello World\n") });
  }
}

main();

