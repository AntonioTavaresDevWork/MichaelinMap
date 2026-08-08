# How to Set Up the Supabase MCP Server in Claude Code CLI

> Created: 2026-03-30 · Translated to English in S09 (ADR-02)
> A replicable setup, useful to whoever takes this project over and has to point it at a new
> Supabase project.

---

## Context

The Supabase MCP server lets Claude Code interact with the database directly — running SQL, listing
tables, applying migrations and reading logs — without copying and pasting queries by hand. In this
project the orchestrator is the only session that applies migrations through it.

Two things to understand before starting:

- The **configuration is per project** (a `.mcp.json` file at the root of the repository)
- The **access token is per account** — the same token works for every Supabase project you own, and it
  is not scoped to one. It grants access to the whole account, which is why it is a real secret

---

## Prerequisites

| Requirement | Detail |
|---|---|
| Claude Code CLI | Installed and working |
| Supabase account | With an access token generated |
| Node.js / npm | Installed and on the PATH |

Generate the access token at <https://supabase.com/dashboard/account/tokens>. Valid tokens start with
`sbp_`.

> **On handover: do not reuse someone else's token.** Whoever takes the project over generates their own,
> and the previous one is revoked. See the handover section of `README.md`.

---

## Step by step

### Step 1 — Create `.mcp.json` at the project root

Pick one of the two options below.

**Option A — Portable (recommended)**

Uses `npx` directly. Works on any machine without depending on a specific cache path.

```json
{
  "mcpServers": {
    "supabase": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase",
        "--access-token",
        "YOUR_SUPABASE_ACCESS_TOKEN"
      ],
      "env": {}
    }
  }
}
```

**Option B — Direct node path (faster startup)**

Points straight at the module in the npx cache. Faster because it skips npx resolution, but the path is
machine-specific and will not work elsewhere without adjustment.

```json
{
  "mcpServers": {
    "supabase": {
      "type": "stdio",
      "command": "node",
      "args": [
        "C:/Users/<YOUR_USER>/AppData/Local/npm-cache/_npx/<HASH>/node_modules/@supabase/mcp-server-supabase/dist/transports/stdio.js",
        "--access-token",
        "YOUR_SUPABASE_ACCESS_TOKEN"
      ],
      "env": {}
    }
  }
}
```

> If the path does not exist, run `npx @supabase/mcp-server-supabase` once to populate the cache, then
> check the generated path under `AppData/Local/npm-cache/_npx/`. The original version of this document
> had another machine's absolute path hardcoded here, which is exactly the trap Option A avoids.

### Step 2 — Create or update `.claude/settings.local.json`

Add the two keys below. If the file already exists, just add whichever key is missing.

```json
{
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": ["supabase"]
}
```

### Step 3 — Restart Claude Code

Close and reopen Claude Code inside the project directory. The Supabase MCP tools should appear
automatically in the session. **A session started before the file existed will not see them** — this cost
S03 a whole session, because the config was in `mcp.json` and Claude Code reads `.mcp.json`.

---

## Verification

After restarting, confirm the server is active in one of these ways:

- Ask Claude to run a trivial query: `SELECT 1`
- Run `/mcp` inside Claude Code to check the status of the registered servers

---

## Troubleshooting

### 1. The MCP tools do not appear

Check that the access token is passed as a **CLI argument** (`--access-token`), NOT as an environment
variable. This was the number one cause of failure during this project's initial setup.

Wrong:
```json
"env": { "SUPABASE_ACCESS_TOKEN": "sbp_..." }
```

Right:
```json
"args": ["--access-token", "sbp_..."]
```

Also confirm the file is named `.mcp.json`, with the leading dot.

### 2. Cache path not found (Option B)

Run `npx @supabase/mcp-server-supabase` once in the terminal to populate the cache, or switch to Option A.

### 3. Permission denied on Windows

- Try running the terminal as administrator
- Confirm `node` and `npx` are on the PATH: `node --version` and `npx --version` should both answer. A
  shell opened before Node was installed will not see it even when the PATH is correct

### 4. Wrong token format

Valid tokens start with `sbp_`. Generate a new one at
<https://supabase.com/dashboard/account/tokens>.

---

## Important notes

- **The token is per account, not per project** — the same `sbp_...` works for all of your Supabase
  projects
- **The configuration is per project** — `.mcp.json` has to be created in each repository separately
- **`.mcp.json` contains a secret.** It must be in `.gitignore`, and in this repository it already is:
  ```
  .mcp.json
  ```
- **Never kill a `node` process by time window while a session is running.** The MCP server runs through
  `npx`, so it is `node` — the same as Vite. Killing by start time takes the MCP server down with the dev
  server, and only restarting Claude Code brings it back. It happened in S07
- **Tools available** after a correct setup: `execute_sql`, `list_tables`, `apply_migration`,
  `list_migrations`, `get_logs`, `get_advisors`, and others. Note that `apply_migration` rewrites the
  `version` in `schema_migrations` and that sanitizing it afterwards is mandatory — see the
  `michaelinmap-migration` skill
