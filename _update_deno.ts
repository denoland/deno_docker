const DENO_TRACKING_BRANCH = "main";
const AUTOROLL_BRANCH = "autoroll";

function extractVersion() {
}

await run(["git", "checkout", "origin/master"]);

const currentVersion =
  Deno.readTextFileSync("./debian.dockerfile").match(/DENO_VERSION=(.*)/)![1];

console.log(`Starting auto update. Currently on ${currentVersion}`);

async function run(cmd: string[], cwd?: string) {
  const proc = Deno.run({ cmd, cwd });
  const status = await proc.status();
  if (!status.success) {
    console.error(`Failed to run ${cmd.join(" ")}`);
    Deno.exit(1);
  }
}

const newVersion = Deno.version.deno;
if (currentVersion == newVersion) {
  console.log(`No new version available. Staying on ${newVersion}`);
  Deno.exit(0);
}

async function updateDenoVersion(fn: string) {
  console.log(fn);
  const dockerfile = await Deno.readTextFile(fn);
  const updated = dockerfile.replaceAll(
    `DENO_VERSION=${currentVersion}`,
    `DENO_VERSION=${newVersion}`,
  );
  await Deno.writeTextFile(fn, updated);
}

const dockerfiles = [...Deno.readDirSync(".")].filter((e) =>
  e.name.endsWith(".dockerfile")
);
for (const f of dockerfiles) {
  console.log(f.name);
  await updateDenoVersion(f.name);
}

async function updateDockerVersion(fn: string) {
  const contents = await Deno.readTextFile(fn);
  const updated = contents.replaceAll(
    `deno:${currentVersion}`,
    `deno:${newVersion}`,
  );
  await Deno.writeTextFile(fn, updated);
}

for (const fn of ["README.md", "example/Dockerfile"]) {
  console.log(fn);
  await updateDockerVersion(fn);
}

console.log(`Updated to version ${newVersion}`);

throw new Error();

// Stage the changes
await run(["git", "add", "*.dockerfile", "README.md", "example/Dockerfile"]);

// Commit the changes
await run(["git", "commit", "-m", `Rolling to deno ${newVersion}`]);

// Push to the `hayd/deno-docker#autoroll`
await run(["git", "push", "origin", `+HEAD:${AUTOROLL_BRANCH}`]);

const proc = Deno.run({
  cmd: ["gh", "pr", "view", AUTOROLL_BRANCH],
});
const status = await proc.status();
if (status.code == 1) {
  console.log("No PR open. Creating a new PR.");
  await run([
    "gh",
    "pr",
    "create",
    "--fill",
    "--head",
    AUTOROLL_BRANCH,
  ]);
} else {
  console.log("Already open PR. Editing existing PR.");
  await run([
    "gh",
    "pr",
    "edit",
    AUTOROLL_BRANCH,
    "--title",
    `Rolling to deno ${newVersion}`,
  ]);
}
