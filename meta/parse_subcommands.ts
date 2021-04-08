// deno --help | deno run parse_subcommands.ts <pipe-separated command list>

import { joinListWithIndent } from "./utils.ts";

const parseError = new Error("Subcommands could not be parsed");

function parseLine(line: string): [name: string, description: string] {
  const regex = /^\s*(?<name>[^\s]+)\s+(?<description>.+)$/u;
  const { name, description } = line.trim().match(regex)?.groups ?? {};
  if (!name || !description) throw parseError;
  return [name, description];
}

export function parseSubcommands(helpText: string): Record<string, string> {
  const lines = helpText.split("\n");
  const startIndex =
    lines.findIndex((line) => line.trim().toLowerCase() === "subcommands:") + 1;
  if (startIndex === 0) throw parseError;
  const subcommands = {} as Record<string, string>;

  for (let i = startIndex; i < lines.length - 1; i += 1) {
    const line = lines[i];
    if (!line.trim()) break;
    const [name, description] = parseLine(line);
    subcommands[name] = description;
  }

  return subcommands;
}

function compareSets<T extends string | number>(setA: Set<T>, setB: Set<T>): {
  a: T[];
  b: T[];
  common: T[];
  same: boolean;
} {
  let same = setA.size === setB.size;
  if (same) {
    for (const val of setA) {
      if (setB.has(val)) continue;
      same = false;
      break;
    }
  }

  if (same) return { a: [], b: [], common: [...setA].sort(), same };

  const common = [...setA].filter((val) => setB.has(val)).sort();
  const a = [...setA].filter((val) => !setB.has(val)).sort();
  const b = [...setB].filter((val) => !setA.has(val)).sort();
  return { a, b, common, same };
}

async function main(): Promise<void> {
  const arg = Deno.args[0] ?? "";
  const inputList = new Set(
    arg.split("|")
      .map((str) => str.trim())
      .filter((str) => str.length),
  );
  if (inputList.size === 0) throw new Error("No input list provided");
  const stdin = new TextDecoder().decode(await Deno.readAll(Deno.stdin));
  const subcommands = parseSubcommands(stdin);
  const helpList = new Set(Object.keys(subcommands));
  const { a, b, common } = compareSets(inputList, helpList);
  console.log(`common:\n${joinListWithIndent(common)}`);
  console.log(`only in input list:\n${joinListWithIndent(a)}`);
  console.log(`only in deno help:\n${joinListWithIndent(b)}`);
}

if (import.meta.main) main();
