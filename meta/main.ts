// deno run --allow-run meta/main.ts <command>
// e.g. deno run --allow-run meta/main.ts entry > _entry.sh

import { entry } from "./entry.ts";
import { exitWithMessage, joinListWithIndent } from "./utils.ts";
import { parse } from "./deps.ts";

enum Command {
  Entry = "entry",
}

const commandList = `\n\n${joinListWithIndent([...Object.values(Command)])}\n`;

async function main(): Promise<void> {
  const args = parse(Deno.args);
  const [command] = args._;
  if (typeof command === "undefined") {
    const message =
      `No command argument provided. The following commands can be used:${commandList}`;
    exitWithMessage(message);
  }
  const remainingArgs = args._.slice(1);

  switch (command) {
    case Command.Entry: {
      await entry(remainingArgs);
      break;
    }
    default: {
      const message =
        `Command "${command}" not recognized. The following commands can be used:${commandList}`;
      exitWithMessage(message);
    }
  }
}

if (import.meta.main) main();
