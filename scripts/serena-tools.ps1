param(
  [switch]$AddMcp,
  [switch]$Index,
  [switch]$StartServer,
  [string]$Context = "agent",
  [string]$Mode = "editing",
  [ValidateSet('stdio','sse','streamablehttp')]
  [string]$Transport = 'sse',
  [int]$Port = 9121
)

function Add-SerenaMcp {
  Write-Host "Registering Serena MCP server for this workspace..." -ForegroundColor Green
  try {
    $command = "claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant --project $PWD.Path"
    Write-Host "Running: $command" -ForegroundColor Yellow
    Invoke-Expression $command
    Write-Host "Serena MCP server registered successfully!" -ForegroundColor Green
  } catch {
    Write-Host "Failed to register Serena MCP server: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure 'claude' CLI is installed and uv is available." -ForegroundColor Yellow
  }
}

function Invoke-SerenaIndex {
  Write-Host "Indexing project with Serena..." -ForegroundColor Green
  try {
    $command = "uvx --from git+https://github.com/oraios/serena index-project"
    Write-Host "Running: $command" -ForegroundColor Yellow
    Invoke-Expression $command
    Write-Host "Project indexed successfully!" -ForegroundColor Green
  } catch {
    Write-Host "Failed to index project: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure uv is installed. Install with: iwr https://astral.sh/uv/install.ps1 -UseBasicParsing | iex" -ForegroundColor Yellow
  }
}

function Start-SerenaServer {
  Write-Host "Starting Serena MCP server locally..." -ForegroundColor Green
  Write-Host "Context: $Context, Mode: $Mode, Transport: $Transport, Port: $Port" -ForegroundColor Cyan

  $scriptPath = ".\tools\scripts\start-serena-mcp.ps1"
  if (!(Test-Path $scriptPath)) {
    Write-Host "Error: Serena startup script not found at $scriptPath" -ForegroundColor Red
    return
  }

  try {
    & $scriptPath -Context $Context -Mode $Mode -Transport $Transport -Port $Port
  } catch {
    Write-Host "Failed to start Serena server: $($_.Exception.Message)" -ForegroundColor Red
  }
}

function Show-Help {
  Write-Host "Serena MCP Tools for PowerShell" -ForegroundColor Cyan
  Write-Host "================================" -ForegroundColor Cyan
  Write-Host ""
  Write-Host "Usage:" -ForegroundColor Yellow
  Write-Host "  .\scripts\serena-tools.ps1 -AddMcp          # Register MCP server with Claude"
  Write-Host "  .\scripts\serena-tools.ps1 -Index           # Index the project"
  Write-Host "  .\scripts\serena-tools.ps1 -StartServer     # Start local MCP server"
  Write-Host ""
  Write-Host "Parameters for -StartServer:" -ForegroundColor Yellow
  Write-Host "  -Context <string>    # Context (default: 'agent')"
  Write-Host "  -Mode <string>       # Mode (default: 'editing')"
  Write-Host "  -Transport <string>  # Transport: stdio, sse, streamablehttp (default: 'sse')"
  Write-Host "  -Port <int>          # Port for SSE transport (default: 9121)"
  Write-Host ""
  Write-Host "Examples:" -ForegroundColor Yellow
  Write-Host "  .\scripts\serena-tools.ps1 -AddMcp"
  Write-Host "  .\scripts\serena-tools.ps1 -Index"
  Write-Host "  .\scripts\serena-tools.ps1 -StartServer -Context 'agent' -Port 9121"
}

# Main logic
if ($AddMcp) {
  Add-SerenaMcp
} elseif ($Index) {
  Invoke-SerenaIndex
} elseif ($StartServer) {
  Start-SerenaServer
} else {
  Show-Help
}