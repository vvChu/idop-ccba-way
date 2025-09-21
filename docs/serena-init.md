# Serena MCP - Initialization Prompt

Use this at the start of each coding session with Claude Code (or any MCP client).

## System/Init instruction for the agent

```
Discover available MCP tools and resources from the connected "serena" MCP server.

For any task on this repository:
1) Use Serena's semantic retrieval to find the smallest, most relevant set of files/snippets.
2) Explain what you retrieved and why it's relevant.
3) Propose changes as diffs/patches. Keep edits minimal and localized.
4) After changes, suggest tests or quick checks to validate behavior.

Never load or summarize the entire repository unless explicitly asked.
Prefer reading spec/*.json and scripts/*.ps1 first for SharePoint provisioning tasks in this repo.
If the index looks stale, ask me to run "Serena: Index project" and then retry retrieval.

Repository context:
- This is a PowerShell/SharePoint provisioning project (idop-ccba-way)
- Key areas: SharePoint lists, taxonomy, Power Automate flows, PnP PowerShell scripts
- Specs in: specs/modules/*/ (JSON schemas for business logic)
- Scripts in: tools/scripts/ (PowerShell automation)
- Data models in: datamodel/sharepoint/ (list definitions, schemas)
```

## Quick Start Commands

### For Claude Code users
```bash
# Add MCP server (one-time setup)
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant --project "$(pwd)"

# Index project
uvx --from git+https://github.com/oraios/serena index-project
```

### For VS Code users
- Run "Serena: Add MCP server (workspace)" task
- Run "Serena: Index project" task
- Run "Serena: Start MCP server (local)" task

### For PowerShell users
```powershell
# Add MCP server
.\scripts\serena-tools.ps1 -AddMcp

# Index project
.\scripts\serena-tools.ps1 -Index

# Start local server
.\scripts\serena-tools.ps1 -StartServer
```

## Workflow Example

When you need to "add a field to Opportunities and update deployment script":

1. **Index**: Run "Serena: Index project" task
2. **Query**: "Use Serena to retrieve all files strongly related to 'opportunities schema' and 'SharePoint list provisioning'. Propose changes and show unified diff. Then explain impact."
3. **Review**: Agent will retrieve relevant files like:
  - `spec/modules/strategy_crm/opportunities.json`
  - `tools/scripts/deploy-sp-lists-enhanced.ps1`
4. **Apply**: Review diff → Apply changes → Re-index if needed

## Best Practices

- **Re-index** after major changes (refactor, new modules)
- **Add comments** with keywords: `# area:sharepoint-provisioning`, `# module:strategy_crm`, `# relates:customers.json`
- **Keep structure clean** for better retrieval
- **Ignore sensitive data** in .gitignore
- **Monitor dashboard** at http://127.0.0.1:24283/dashboard/index.html for logs

## Troubleshooting

- **Index stale?** Run "Serena: Index project"
- **Server not responding?** Check if port 9121 is free
- **Tools not available?** Verify MCP server is registered with your client
- **Poor retrieval?** Add more descriptive comments and re-index