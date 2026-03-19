import express from "express";
import chalk from "chalk";
import { upperCase } from "lodash-es";

const PORT = 1993;
const app = express();

app.get("/", (_req, res) => {
  res.send(upperCase("Hello World") + "\n");
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(chalk.green(`Server started on port ${PORT}`));
});
