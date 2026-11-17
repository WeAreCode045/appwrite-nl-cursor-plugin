#!/usr/bin/env node
/**
 * Minimal stdio MCP: persists plugin Configure variable APPWRITE_ENDPOINT
 * to ~/.cursor/appwrite-nl/default-endpoint for appwrite-mcp.sh (project API MCP).
 * Tools: none — config side-effect on start + optional tools/list empty.
 */
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import readline from "node:readline";

const STATE_DIR = path.join(os.homedir(), ".cursor", "appwrite-nl");
const STATE_FILE = path.join(STATE_DIR, "default-endpoint");

function persistEndpoint() {
  const raw = (process.env.APPWRITE_DEFAULT_ENDPOINT || "").trim();
  if (!raw || raw.includes("${")) {
    process.stderr.write(
      "appwrite-endpoint: no APPWRITE_DEFAULT_ENDPOINT yet — set Plugins → Configure → Default Appwrite endpoint\n"
    );
    return;
  }
  fs.mkdirSync(STATE_DIR, { recursive: true });
  fs.writeFileSync(STATE_FILE, `${raw}\n`, "utf8");
  process.stderr.write(`appwrite-endpoint: default endpoint -> ${raw}\n`);
}

persistEndpoint();

function send(msg) {
  const body = JSON.stringify(msg);
  process.stdout.write(`Content-Length: ${Buffer.byteLength(body, "utf8")}\r\n\r\n${body}`);
}

function handleMessage(msg) {
  if (!msg || typeof msg !== "object") return;
  const { id, method } = msg;
  if (method === "initialize") {
    send({
      jsonrpc: "2.0",
      id,
      result: {
        protocolVersion: msg.params?.protocolVersion || "2024-11-05",
        capabilities: { tools: {} },
        serverInfo: { name: "appwrite-endpoint", version: "1.0.0" },
      },
    });
    return;
  }
  if (method === "notifications/initialized" || method === "notifications/cancelled") return;
  if (method === "tools/list") {
    send({ jsonrpc: "2.0", id, result: { tools: [] } });
    return;
  }
  if (method === "ping") {
    send({ jsonrpc: "2.0", id, result: {} });
    return;
  }
  if (id != null) {
    send({
      jsonrpc: "2.0",
      id,
      error: { code: -32601, message: `Method not found: ${method}` },
    });
  }
}

let buffer = Buffer.alloc(0);
process.stdin.on("data", (chunk) => {
  buffer = Buffer.concat([buffer, chunk]);
  while (true) {
    const headerEnd = buffer.indexOf("\r\n\r\n");
    if (headerEnd === -1) {
      // Newline-delimited JSON fallback (some hosts)
      const nl = buffer.indexOf("\n");
      if (nl === -1) return;
      const line = buffer.slice(0, nl).toString("utf8").trim();
      buffer = buffer.slice(nl + 1);
      if (!line || line.toLowerCase().startsWith("content-length:")) continue;
      try {
        handleMessage(JSON.parse(line));
      } catch {
        /* ignore */
      }
      continue;
    }
    const header = buffer.slice(0, headerEnd).toString("utf8");
    const match = /Content-Length:\s*(\d+)/i.exec(header);
    if (!match) {
      buffer = buffer.slice(headerEnd + 4);
      continue;
    }
    const length = Number(match[1]);
    const bodyStart = headerEnd + 4;
    if (buffer.length < bodyStart + length) return;
    const body = buffer.slice(bodyStart, bodyStart + length).toString("utf8");
    buffer = buffer.slice(bodyStart + length);
    try {
      handleMessage(JSON.parse(body));
    } catch {
      /* ignore */
    }
  }
});

process.stdin.on("end", () => process.exit(0));
