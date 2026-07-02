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
      name: "assessment-auth-backend",
      cwd: "/Users/eko/dev/SuperApp/assessment/auth/backend/",
      script: "/bin/bash",
      args: "-lc 'jar=$(find target -maxdepth 1 -type f -name \"*.jar\" ! -name \"original-*.jar\" | head -n1); if [[ -z \"$jar\" ]]; then echo \"No built jar found in target\" >&2; exit 1; fi; exec java -jar \"$jar\"'",
      exec_mode: "fork",
      env: { SERVER_PORT: 2001 },
    },
