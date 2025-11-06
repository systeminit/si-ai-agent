#Requires -Version 5.0
Set-StrictMode -Version Latest

# Colors for output
$RED = "`e[0;31m"
$YELLOW = "`e[1;33m"
$GREEN = "`e[0;32m"
$BLUE = "`e[0;34m"
$NC = "`e[0m" # No Color

# Function to check if command exists
function Command-Exists {
    param([string]$Command)

    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# Function to display error message for claude
function Show-ClaudeInstallationError {
    Write-Host "${RED}❌ Error: 'claude' is not installed!${NC}" -ForegroundColor Red
    Write-Host "${YELLOW}📖 Please follow the documentation at: https://www.anthropic.com/claude-code${NC}" -ForegroundColor Yellow
    Write-Host "${YELLOW}💡 Summary: Install Node.js and run 'npm install -g @anthropic-ai/claude-code'${NC}" -ForegroundColor Yellow
}

# Function to display error message for docker
function Show-DockerInstallationError {
    Write-Host "${RED}❌ Error: 'docker' is not installed!${NC}" -ForegroundColor Red
    Write-Host "${YELLOW}🐳 Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/${NC}" -ForegroundColor Yellow
}

# Function to prompt for API token
function Prompt-ForApiToken {
    Write-Host ""
    Write-Host "${BLUE}🔑 System Initiative API Token Required${NC}" -ForegroundColor Cyan
    Write-Host "${YELLOW}To get your API token:${NC}" -ForegroundColor Yellow
    Write-Host "${YELLOW}1. Go to: https://auth.systeminit.com/workspaces${NC}" -ForegroundColor Yellow
    Write-Host "${YELLOW}2. Click the 'gear' icon for your workspace${NC}" -ForegroundColor Yellow
    Write-Host "${YELLOW}3. Select 'API Tokens'${NC}" -ForegroundColor Yellow
    Write-Host "${YELLOW}4. Name it 'claude code'${NC}" -ForegroundColor Yellow
    Write-Host "${YELLOW}5. Generate a new token with 1y expiration${NC}" -ForegroundColor Yellow
    Write-Host "${YELLOW}6. Copy the token from the UI${NC}" -ForegroundColor Yellow
    Write-Host ""

    $token = ""
    while ($true) {
        Write-Host "${BLUE}Please paste your API token:${NC}" -ForegroundColor Cyan
        $token = Read-Host -AsSecureString
        $token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($token))

        if ([string]::IsNullOrWhiteSpace($token)) {
            Write-Host "${RED}❌ Token cannot be empty${NC}" -ForegroundColor Red
            continue
        }

        # Basic JWT format validation (three base64 parts separated by dots)
        if ($token -match '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$') {
            Set-Item -Path "env:SI_API_TOKEN" -Value $token
            Write-Host "${GREEN}✅ API token set successfully${NC}" -ForegroundColor Green
            break
        }
        else {
            Write-Host "${RED}❌ Invalid token format. System Initiative tokens are JWTs${NC}" -ForegroundColor Red
        }
    }
}

# Function to create .mcp.json file
function Create-McpConfig {
    param(
        [string]$McpFile = ""
    )

    if ([string]::IsNullOrWhiteSpace($McpFile)) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        $McpFile = Join-Path $scriptDir ".mcp.json"
    }

    Write-Host "${BLUE}📄 Creating MCP configuration file${NC}" -ForegroundColor Cyan

    $apiToken = $env:SI_API_TOKEN
    if ([string]::IsNullOrWhiteSpace($apiToken)) {
        $apiToken = ""
    }

    $mcpConfig = @{
        mcpServers = @{
            "system-initiative" = @{
                type    = "stdio"
                command = "docker"
                args    = @(
                    "run",
                    "-i",
                    "--rm",
                    "--pull=always",
                    "-e",
                    "SI_API_TOKEN",
                    "systeminit/si-mcp-server:stable"
                )
                env     = @{
                    SI_API_TOKEN = $apiToken
                }
            }
        }
    } | ConvertTo-Json -Depth 10

    $mcpConfig | Out-File -FilePath $McpFile -Encoding UTF8 -Force

    Write-Host "${GREEN}✅ Created .mcp.json at: $McpFile${NC}" -ForegroundColor Green
}

# Main script logic
function Main {
    param(
        [string]$McpConfigFile = ""
    )

    # Check if claude is installed
    if (-not (Command-Exists "claude")) {
        Show-ClaudeInstallationError
        exit 1
    }
    Write-Host "✅ claude is installed and available" -ForegroundColor Green

    # Check if docker is installed
    if (-not (Command-Exists "docker")) {
        Show-DockerInstallationError
        exit 1
    }
    Write-Host "✅ docker is installed and available" -ForegroundColor Green

    # Check if API token is already set in environment
    if (-not [string]::IsNullOrWhiteSpace($env:SI_API_TOKEN)) {
        Write-Host "${GREEN}🔑 Found existing SI_API_TOKEN in environment${NC}" -ForegroundColor Green
        $useExisting = Read-Host "${BLUE}Use existing token? (y/n)${NC}"

        if ($useExisting -match '^[Yy]$') {
            Write-Host "✅ Using existing SI_API_TOKEN" -ForegroundColor Green
            Create-McpConfig -McpFile $McpConfigFile
            return
        }
    }

    # Prompt for API token
    Prompt-ForApiToken

    # Create MCP configuration file
    Create-McpConfig -McpFile $McpConfigFile
}

# Execute main function
Main @args
