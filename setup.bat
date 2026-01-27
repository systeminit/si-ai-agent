@echo off
setlocal enabledelayedexpansion

REM Colors and formatting (using ASCII codes where possible)
REM Note: Batch doesn't support ANSI colors natively, so we'll use simple text formatting

REM Function to check if command exists
:command_exists
where %1 >nul 2>nul
if %errorlevel% equ 0 (
    exit /b 0
) else (
    exit /b 1
)

REM Function to display error message for claude
:show_claude_installation_error
echo.
echo Error: 'claude' is not installed!
echo Please follow the documentation at: https://www.anthropic.com/claude-code
echo Summary: Install Node.js and run 'npm install -g @anthropic-ai/claude-code'
echo.
exit /b 1

REM Function to display error message for docker
:show_docker_installation_error
echo.
echo Error: 'docker' is not installed!
echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/
echo.
exit /b 1

REM Function to prompt for API token
:prompt_for_api_token
echo.
echo System Initiative API Token Required
echo To get your API token:
echo 1. Go to: https://auth.systeminit.com/workspaces
echo 2. Click the 'gear' icon for your workspace
echo 3. Select 'API Tokens'
echo 4. Name it 'claude code'
echo 5. Generate a new token with 1y expiration
echo 6. Copy the token from the UI
echo.

:token_input_loop
set /p "token=Please paste your API token: "

if "!token!"=="" (
    echo Error: Token cannot be empty
    goto token_input_loop
)

REM Basic validation - check if token contains dots (JWT format)
echo !token! | findstr /r "^[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*$" >nul
if %errorlevel% neq 0 (
    echo Error: Invalid token format. System Initiative tokens are JWTs
    goto token_input_loop
)

set "SI_API_TOKEN=!token!"
echo API token set successfully
exit /b 0

REM Function to create .mcp.json file
:create_mcp_config
setlocal enabledelayedexpansion
set "mcp_file=%~1"

if "!mcp_file!"=="" (
    set "mcp_file=%~dp0.mcp.json"
)

echo Creating MCP configuration file

(
echo {
echo   "mcpServers": {
echo     "system-initiative": {
echo       "type": "stdio",
echo       "command": "docker",
echo       "args": [
echo         "run",
echo         "-i",
echo         "--rm",
echo         "--pull=always",
echo         "-e",
echo         "SI_API_TOKEN",
echo         "systeminit/si-mcp-server:stable"
echo       ],
echo       "env": {
echo         "SI_API_TOKEN": "!SI_API_TOKEN!"
echo       }
echo     }
echo   }
echo }
) > "!mcp_file!"

echo Created .mcp.json at: !mcp_file!
endlocal
exit /b 0

REM Main script logic
:main
set "mcp_config_file=%~1"

REM Check if claude is installed
where claude >nul 2>nul
if %errorlevel% neq 0 (
    call :show_claude_installation_error
    exit /b 1
)
echo Check: claude is installed and available

REM Check if docker is installed
where docker >nul 2>nul
if %errorlevel% neq 0 (
    call :show_docker_installation_error
    exit /b 1
)
echo Check: docker is installed and available

REM Check if API token is already set in environment
if not "!SI_API_TOKEN!"=="" (
    echo Found existing SI_API_TOKEN in environment
    set /p "use_existing=Use existing token? (y/n): "

    if /i "!use_existing!"=="y" (
        echo Using existing SI_API_TOKEN
        call :create_mcp_config "!mcp_config_file!"
        exit /b 0
    )
)

REM Prompt for API token
call :prompt_for_api_token
if %errorlevel% neq 0 (
    exit /b 1
)

REM Create MCP configuration file
call :create_mcp_config "!mcp_config_file!"

exit /b 0

REM Execute main function
call :main %*
