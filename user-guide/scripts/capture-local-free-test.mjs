import fs from "node:fs";

const output = process.argv[2] || "user-guide/screenshots/local/tes-gratis-soal-teruji-lokal.png";
const pages = await (await fetch("http://127.0.0.1:9222/json")).json();
const page = pages.find((entry) => entry.type === "page");
if (!page) throw new Error("Chrome page target unavailable");

const socket = new WebSocket(page.webSocketDebuggerUrl);
await new Promise((resolve, reject) => {
  socket.addEventListener("open", resolve, { once: true });
  socket.addEventListener("error", reject, { once: true });
});

let next = 0;
const pending = new Map();
socket.addEventListener("message", ({ data }) => {
  const message = JSON.parse(data);
  if (message.id && pending.has(message.id)) {
    const handler = pending.get(message.id);
    pending.delete(message.id);
    message.error ? handler.reject(new Error(message.error.message)) : handler.resolve(message.result);
  }
});
const call = (method, params = {}) => new Promise((resolve, reject) => {
  const id = ++next;
  pending.set(id, { resolve, reject });
  socket.send(JSON.stringify({ id, method, params }));
});

try {
  await call("Network.enable");
  const token = JSON.parse(fs.readFileSync("/tmp/assessment-local-signup.json", "utf8")).token;
  await call("Network.setCookie", {
    name: "assessment_token",
    value: token,
    url: "http://127.0.0.1:4902/",
    httpOnly: true,
  });
  await call("Page.enable");
  await call("Emulation.setDeviceMetricsOverride", {
    width: 1440,
    height: 1100,
    deviceScaleFactor: 1,
    mobile: false,
  });
  await call("Page.navigate", { url: "http://127.0.0.1:4902/tes-gratis/soal" });
  await new Promise((resolve) => setTimeout(resolve, 3500));
  const image = await call("Page.captureScreenshot", { format: "png", captureBeyondViewport: false });
  fs.writeFileSync(output, Buffer.from(image.data, "base64"));
  const title = await call("Runtime.evaluate", { expression: "document.title", returnByValue: true });
  const text = await call("Runtime.evaluate", { expression: "document.body.innerText.slice(0,800)", returnByValue: true });
  process.stdout.write(JSON.stringify({ title: title.result.value, excerpt: text.result.value.replace(/\\s+/g, " ").slice(0, 400) }));
} finally {
  socket.close();
}
