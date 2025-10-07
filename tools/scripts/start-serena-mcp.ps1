# Script khởi động Serena MCP server và hướng dẫn inject prompt cho agent
# Sử dụng: ./start-serena-mcp.ps1 [-Context "agent"] [-Mode "editing"] [-Transport sse] [-Port 9121]
param(
    [string]$Context = "agent",
    [string]$Mode = "editing",
    [ValidateSet('stdio','sse','streamablehttp')]
    [string]$Transport = 'sse',
    # Mặc định dùng 9121 cho MCP SSE (dashboard dùng 24282)
    [int]$Port = 9121
)

# Function to log messages with timestamp
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Level] $timestamp - $Message"
}

# Function to check if path exists
function Test-PathExists {
    param([string]$Path, [string]$Description)
    if (!(Test-Path $Path)) {
        Write-Log "Không tìm thấy $Description tại $Path" "ERROR"
        return $false
    }
    return $true
}

# Function to run indexing using available tools (venv python/CLI or uvx fallback)
function Invoke-Indexing {
    try {
        Write-Log "Đang index codebase (không yêu cầu kích hoạt venv)..."
        Push-Location "serena"

        $pythonExe = ".venv\Scripts\python.exe"
        $serenaCli = $null
        if (Test-Path $pythonExe) {
            # Try using installed serena CLI via python -m
            Write-Log "Tìm thấy python trong venv: $pythonExe"
            & $pythonExe -m serena.scripts.index_project 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Indexing qua python module hoàn tất."
                Pop-Location
                return
            }
        }

        # Try serena CLI directly if on PATH
        try {
            $serenaCli = (Get-Command serena -ErrorAction Stop).Source
        } catch { $serenaCli = $null }
        if ($serenaCli) {
            serena project index .
            if ($LASTEXITCODE -eq 0) { Write-Log "Indexing bằng serena CLI hoàn tất." } else { Write-Log "Indexing bằng serena CLI có lỗi (mã: $LASTEXITCODE)." "WARNING" }
            Pop-Location
            return
        }

        # Fallback to uvx if available
        try {
            $uvx = (Get-Command uvx -ErrorAction Stop).Source
        } catch { $uvx = $null }
        if ($uvx) {
            Write-Log "Fallback: dùng uvx để index..."
            uvx --from git+https://github.com/oraios/serena index-project
            if ($LASTEXITCODE -eq 0) { Write-Log "Indexing bằng uvx hoàn tất." } else { Write-Log "Indexing bằng uvx có lỗi (mã: $LASTEXITCODE)." "WARNING" }
            Pop-Location
            return
        }

        Write-Log "Không tìm thấy phương thức indexing phù hợp (python/serena/uvx)." "WARNING"
        Pop-Location
    } catch {
        Write-Log "Lỗi trong quá trình indexing: $($_.Exception.Message)" "ERROR"
        try { Pop-Location } catch {}
    }
}

# Function to start MCP server
function Start-MCPServer {
    param([string]$Context, [string]$Mode, [string]$Transport, [int]$Port)

    $serenaPath = "serena\scripts\mcp_server.py"
    $hasScriptFile = Test-Path $serenaPath
    if (-not $hasScriptFile) {
        Write-Log "Không tìm thấy script local, sẽ thử chạy python module 'serena.scripts.mcp_server'" "WARNING"
    }

    Write-Log "Đang khởi động Serena MCP server với context: $Context, mode: $Mode, transport: $Transport, port: $Port"

    try {
        # Change to serena directory to use its venv
        Push-Location "serena"
        
        $mcpArgs = @()
        if ($hasScriptFile) {
            $mcpArgs = @("scripts\mcp_server.py", "--context", $Context, "--mode", $Mode, "--transport", $Transport)
        } else {
            # Use -m serena.scripts.mcp_server
            $mcpArgs = @("-m", "serena.scripts.mcp_server", "--context", $Context, "--mode", $Mode, "--transport", $Transport)
        }
        if ($Transport -eq 'sse' -or $Transport -eq 'streamablehttp') {
            # Bind MCP HTTP transport to localhost and specified port to avoid collision with dashboard (24282)
            $mcpArgs += @("--host", "127.0.0.1", "--port", $Port)
        }

        $pythonExe = ".venv\Scripts\python.exe"
        if (!(Test-Path $pythonExe)) {
            Write-Log "Không tìm thấy Python trong venv, thử dùng 'python' trên PATH." "WARNING"
            $pythonExe = "python"
        }

        $process = Start-Process -NoNewWindow -FilePath $pythonExe -ArgumentList $mcpArgs -PassThru
        Write-Log "MCP server đã được khởi động (PID: $($process.Id))"
        
        Pop-Location
    } catch {
        Write-Log "Lỗi khi khởi động MCP server: $($_.Exception.Message)" "ERROR"
        exit 1
    }
}

# Main execution
Write-Log "Bắt đầu quá trình khởi động Serena MCP"

# Validate parameters
if ([string]::IsNullOrEmpty($Context)) {
    Write-Log "Context không được để trống." "ERROR"
    exit 1
}
if ([string]::IsNullOrEmpty($Mode)) {
    Write-Log "Mode không được để trống." "ERROR"
    exit 1
}

# Run indexing
Invoke-Indexing

# Start MCP server
Start-MCPServer -Context $Context -Mode $Mode -Transport $Transport -Port $Port

# Display integration instructions
Write-Log "Để tích hợp với AI agent (Copilot, Claude, Cursor):"
Write-Host "- Inject prompt hướng dẫn sử dụng Serena MCP vào agent (xem docs/serena_on_chatgpt.md hoặc serena/README.md)"
Write-Host "- Đảm bảo agent truy vấn MCP server trước khi xử lý yêu cầu code."
Write-Host "- Có thể viết extension hoặc alias tự động hóa bước này cho VS Code."
