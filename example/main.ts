import { serve } from "./deps.ts";

const PORT = 1993;
const s = serve(`0.0.0.0:${PORT}`);
const body = new TextEncoder().encode("Hello World\n");

window.onload = async () => {
  console.log(`Server started on port ${PORT}`);
  for await (const req of s) {
    req.respond({ body });
  }
};
