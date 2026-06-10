module.exports = {
  apps: [
    {
      name: "assessment-auth-backend",
      cwd: "../auth/backend",
      script: "mvn",
      args: "spring-boot:run",
      exec_mode: "fork",
      interpreter: "none",
      env: { PORT: 2000 },
      watch: ["src/main/java/**/*.java", "src/main/resources/**/*.properties", "src/main/resources/**/*.yml"],
      watch_delay: 1500,
      ignore_watch: ["node_modules", "target"],
    },
    {
      name: "assessment-index",
      cwd: ".",
      script: "npm",
      args: "run dev",
      exec_mode: "fork",
      interpreter: "none",
      env: { PORT: 2001 },
    },
  ]
};
