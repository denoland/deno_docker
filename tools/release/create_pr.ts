#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-net --allow-run=git --no-check
// Copyright 2018-2023 the Deno authors. All rights reserved. MIT license.
import { createOctoKit, getGitHubRepository, parseYaml } from "./deps.ts";
import { loadRepo } from "./repo.ts";

const octoKit = createOctoKit();
const repo = await loadRepo();
const newVersion = parseYaml(await Deno.readTextFile(".bmp.yml")).version;

const originalBranch = await repo.gitCurrentBranch();
const newBranchName = `release_${newVersion.replace(/\./, "_")}`;

// Create and push branch
console.log(`Creating branch ${newBranchName}...`);
await repo.gitBranch(newBranchName);
await repo.gitAdd();
await repo.gitCommit(newVersion);
console.log("Pushing branch...");
await repo.gitPush("-u", "origin", "HEAD");

// Open PR
console.log("Opening PR...");
const openedPr = await octoKit.request("POST /repos/{owner}/{repo}/pulls", {
  ...getGitHubRepository(),
  base: originalBranch,
  head: newBranchName,
  draft: true,
  title: newVersion,
  body: getPrBody(),
});
console.log(`Opened PR at ${openedPr.data.url}`);

function getPrBody() {
  let text = `Bumped version for ${newVersion}\n\n` +
    `Please ensure:\n` +
    `- [ ] Version in README.md is updated correctly\n` +
    `- [ ] Dockerfiles are updated correctly\n\n` +
    `To make edits to this PR:\n` +
    "```shell\n" +
    `git fetch upstream ${newBranchName} && git checkout -b ${newBranchName} upstream/${newBranchName}\n` +
    "```\n";

  const actor = Deno.env.get("GH_WORKFLOW_ACTOR");
  if (actor != null) {
    text += `\ncc @${actor}`;
  }

  return text;
}
