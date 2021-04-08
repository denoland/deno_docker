export function exitWithMessage(message: string | string[], code = 1): never {
  const messages = Array.isArray(message) ? message : [message];
  const consoleMethod = code === 1 ? "error" : "log";
  for (const message of messages) console[consoleMethod](message);
  Deno.exit(code);
}

export function joinListWithIndent(list: string[], spaces = 2): string {
  return list.map((str) => str.padStart(str.length + spaces, " ")).join("\n");
}
