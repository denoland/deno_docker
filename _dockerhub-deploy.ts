const DENO_VERSION = '0.23.0';

console.log("Building and pushing", DENO_VERSION);
for (const name of ["alpine", "debian", "ubuntu"]) {
  const p1 = Deno.run({
    args: [
      "docker",
      "build",
      "-f",
      `${name}.dockerfile`,
      "-t",
      `hayd/deno:${name}-${DENO_VERSION}`,
      "."
    ],
    stdout: "piped"
  });
  const s1 = await p1.status();
  if (!s1.success) {
    const o1 = new TextDecoder().decode(await p1.output());
    console.log(o1);
    console.error(`Building ${name} failed`);
    Deno.exit(1);
  }

  const p2 = Deno.run({
    args: ["docker", "run", "-it", `hayd/deno:${name}-${DENO_VERSION}`],
    stdout: "piped"
  });
  const s2 = await p2.status();
  const o2 = new TextDecoder().decode(await p2.output());
  console.log(name, o2);
  if (!s2.success) {
    console.error("Failed to run", name);
    Deno.exit(1);
  }

  const p3 = Deno.run({
    args: ["docker", "push", `hayd/deno:${name}-${DENO_VERSION}`],
    stdout: "piped"
  });
  const s3 = await p3.status();
  if (!s3.success) {
    const o3 = new TextDecoder().decode(await p3.output());
    console.log(o3);
    console.error(`Pushing ${name} failed`);
    Deno.exit(1);
  }
}

// TODO build amazonlinux-1.dockerfile and upload binary.
