import { describe } from "mocha";
import path from "path";
import fs from "fs";

function loadTestFiles(dir: string) {
  const files = fs.readdirSync(dir);
  files.forEach(file => {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      loadTestFiles(fullPath);
    } else if (file.endsWith(".test.ts")) {
      require(fullPath);
    }
  });
}

describe("Voting IMPROVED Contract Tests", function () {
  const testDir = path.join(__dirname);
  loadTestFiles(testDir);
});
