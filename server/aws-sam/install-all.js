const { execSync } = require("child_process");
const { readdirSync, statSync, existsSync } = require("fs");
const path = require("path");

function walk(dir) {
  readdirSync(dir).forEach(f => {
    const full = path.join(dir, f);

    if (f === "node_modules" || f.startsWith(".")) return;

    if (statSync(full).isDirectory()) {
      const pkg = path.join(full, "package.json");
      if (existsSync(pkg)) {
        console.log(`Installing in ${full}...`);
        execSync("npm install", { cwd: full, stdio: "inherit" });
      }
      walk(full);
    }
  });
}
walk(path.join(__dirname, "app"));
