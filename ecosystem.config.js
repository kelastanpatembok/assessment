export default {
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
      cwd: "./frontend",
      script: "npm",
      args: "run dev",
      exec_mode: "fork",
      interpreter: "none",
      env: { PORT: 2001 },
    },
    {
      name: "assessment-backend",
      cwd: "./backend",
      script: "/Users/eko/maven/bin/mvn",
      args: "spring-boot:run",
      exec_mode: "fork",
      interpreter: "none",
      env: { PORT: 2002, LC_ALL: "C", LANG: "C" },
      watch: ["src/main/java/**/*.java", "src/main/resources/**/*.yml", "src/main/resources/**/*.yaml"],
      watch_delay: 2000,
      ignore_watch: ["node_modules", "target", ".postgres"],
    },
  ]
};
