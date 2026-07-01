module.exports = {
  apps: [
    {
      name: "assessment-assessment-backend",
      cwd: "/Users/eko/dev/SuperApp/assessment/assessment/backend/",
      script: "mvn",
      args: "spring-boot:run",
      exec_mode: "fork",
      env: { SERVER_PORT: 2002 },
      interpreter: "bash",
      watch: ["src/main/java/**/*.java", "src/main/resources/**/*.properties", "src/main/resources/**/*.yml"],
      watch_delay: 1500,
      ignore_watch: ["node_modules", "target"],
    },
    {
      name: "assessment-auth-backend",
      cwd: "/Users/eko/dev/SuperApp/assessment/auth/backend/",
      script: "mvn",
      args: "spring-boot:run",
      exec_mode: "fork",
      env: { SERVER_PORT: 2001 },
      interpreter: "bash",
      watch: ["src/main/java/**/*.java", "src/main/resources/**/*.properties", "src/main/resources/**/*.yml"],
      watch_delay: 1500,
      ignore_watch: ["node_modules", "target"],
    },
    {
      name: "assessment-assessment-frontend",
      cwd: "/Users/eko/dev/SuperApp/assessment/assessment/frontend/",
      script: "/Users/eko/.nvm/versions/node/v20.20.2/bin/npm",
      args: "run dev -- --host 0.0.0.0 --port 2000",
      exec_mode: "fork",
      env: { PORT: 2000, HOST: "0.0.0.0" },
    },
  ]
};
