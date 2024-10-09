import { describe } from "mocha";
import path from "path";
import fs from "fs";

function loadBaseTestFiles(dir: string) {
  const files = fs.readdirSync(dir);
  files.forEach(file => {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      const baseTestPath = path.join(fullPath, "base.test.ts");
      if (fs.existsSync(baseTestPath)) {
        require(baseTestPath);
      }
    }
  });
}

describe("ALL Voting Contracts - General Test Suite", function () {
  const contractsDir = path.join(__dirname);
  loadBaseTestFiles(contractsDir);
});
