module.exports = {
  apps: [
    {
      name: "assessment-assessment-backend",
      cwd: "/Users/eko/dev/SuperApp/assessment/assessment/backend/",
      script: "/bin/bash",
      args: "-lc 'jar=$(find target -maxdepth 1 -type f -name \"*.jar\" ! -name \"original-*.jar\" | head -n1); if [[ -z \"$jar\" ]]; then echo \"No built jar found in target\" >&2; exit 1; fi; exec java -jar \"$jar\"'",
      exec_mode: "fork",
      env: { SERVER_PORT: 2002 },
    },
    {
      name: "assessment-assessment-frontend",
      cwd: "/Users/eko/dev/SuperApp/assessment/assessment/frontend/",
      script: "/Users/eko/.nvm/versions/node/v20.20.2/bin/node",
      args: "build/index.js",
      exec_mode: "fork",
      env: { PORT: 2000, HOST: "0.0.0.0" },
    },
    {
      name: "assessment-auth-backend",
      cwd: "/Users/eko/dev/SuperApp/assessment/auth/backend/",
      script: "/bin/bash",
      args: "-lc 'jar=$(find target -maxdepth 1 -type f -name \"*.jar\" ! -name \"original-*.jar\" | head -n1); if [[ -z \"$jar\" ]]; then echo \"No built jar found in target\" >&2; exit 1; fi; exec java -jar \"$jar\"'",
      exec_mode: "fork",
      env: { SERVER_PORT: 2001 },
    },
  ]
};
