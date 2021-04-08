import { parseSubcommands } from "./parse_subcommands.ts";
import { template } from "./_entry_template.ts";

const decoder = new TextDecoder();

function createEntryScript(denoSubcommands: string[]): string {
  const list = [...denoSubcommands].sort().join(" | ");
  return template.replace("DENO_SUBCOMMANDS_SEPARATED_BY_PIPES", list);
}

export async function entry(args?: (number | string)[]): Promise<void> {
  // const [argument] = args;
  // if (typeof argument === 'undefined') {}
  const p = Deno.run({
    cmd: ["deno", "--help"],
    stderr: "piped",
    stdout: "piped",
  });
  const stderr = decoder.decode(await p.stderrOutput());
  const stdout = decoder.decode(await p.output());
  const { success } = await p.status();
  p.close();
  if (!success) throw new Error(stderr);
  const denoSubcommands = parseSubcommands(stdout);
  const list = Object.keys(denoSubcommands);
  const entryScript = createEntryScript(list);
  console.log(entryScript);
}
