# Runs the Spec Kit "Specify" CLI via uvx directly from the GitHub repo.
# Usage examples:
#   ./tools/speckit/specify.ps1 check
#   ./tools/speckit/specify.ps1 init --here --ai copilot --script ps

param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Args
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command uvx -ErrorAction SilentlyContinue)) {
  Write-Error 'uv is not installed. Please install uv: https://docs.astral.sh/uv/'
  exit 1
}

uvx --from git+https://github.com/github/spec-kit.git specify @Args
