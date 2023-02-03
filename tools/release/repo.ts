// Copyright 2018-2023 the Deno authors. All rights reserved. MIT license.
import { path, Repo } from "./deps.ts";

const currentDirPath = path.dirname(path.fromFileUrl(import.meta.url));
export const rootDirPath = path.resolve(currentDirPath, "../../");

export function loadRepo() {
  return Repo.load({
    name: "deno_docker",
    path: rootDirPath,
  });
}
