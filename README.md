# System Initiative AI Agent

[![Discord Server](https://img.shields.io/badge/discord-gray?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com/invite/system-init)

## NOTICE - NEW METHOD

The original method to run the AI agent is no longer the recommended way of running the System Initiative AI Agent.
You should now use the [`si`](https://github.com/systeminit/si/tree/main/bin/si) binary to do this, which can be installed through one of the following methods based on your platform.

### Installing on Linux and macOS

```bash
curl -fsSL https://auth.systeminit.com/install.sh | sh
```

### Installing on Windows

```shell
irm https://auth.systeminit.com/install.ps1 | iex
```

### Starting the AI Agent

Now that `si` is installed, you can start the agent.

```
si ai-agent init
si ai-agent start
```

---

## ORIGINAL METHOD

This is a repository containing a pre-configured integration between [System Initiative](https://systeminit.com) and [Claude Code](https://www.anthropic.com/claude-code). You will be up and running in under a minute using a single setup script.

### TL;DR

1. Ensure you have a System Initiative Workspace Token.
2. Install [Docker](https://www.docker.com/products/docker-desktop).
3. Install [Claude Code](https://www.anthropic.com/claude-code)
4. Clone the repo and run `./setup.sh`.

### Prerequisites

- **Docker** installed and running (macOS, Linux, or Windows via WSL2)
- **Claude Code** installed and running
- **bash** (the `setup.sh` script is a POSIX‐style shell script)
- A **System Initiative Workspace Token**

> If you’re on Windows, please run the commands inside **WSL2** (Ubuntu recommended).

### Quick start

```bash
# 1) Clone
git clone https://github.com/systeminit/si-ai-agent.git
cd si-ai-agent

# 2) Have your SI workspace token ready (either export it or paste when prompted)
# export SI_WORKSPACE_TOKEN=siu_XXXXXXXXXXXXXXXXXXXXXXXX

# 3) Run the installer
./setup.sh
```

The script will take care of building and running the Dockerized MCP server. If you exported `SI_WORKSPACE_TOKEN`, the script will pick it up automatically; otherwise you’ll be prompted to paste it.

### Configuration

- **`SI_WORKSPACE_TOKEN`** – Your workspace token. You can export it before running, or paste it interactively when `setup.sh` asks.

> **Tip:** The `.mcp.json` is included in the `.gitignore` to avoid committing any tokens to source control. If you place tokens in a local environment file or shell profile, ensure that file is ignored by git too.

### Multiple agents (one per workspace)

Each running **si-ai-agent** connects to **exactly one** System Initiative workspace (1:1).

**Recommended workflow:** use a **separate repo checkout per workspace**.

Example:

```bash
# Workspace A
git clone https://github.com/systeminit/si-ai-agent.git workspace-a
cd workspace-a
export SI_WORKSPACE_TOKEN=siu_...A...
./setup.sh

# Workspace B (separate folder)
git clone https://github.com/systeminit/si-ai-agent.git workspace-b
cd workspace-b
export SI_WORKSPACE_TOKEN=siu_...B...
./setup.sh
```

### Update / Reinstall

Our `.mcp.json` will pull the latest container on startup each time. No need to re-run `./setup.sh`.

### Use Claude from AWS Bedrock

Instead of using an Anthropic account to access Claude, you can use the same model but from your AWS Account's Bedrock Anthropic models. This allows you to pay for it as part of your AWS bill.

You will have to make sure you have enabled the Anthropic Claude model in your AWS Account's [Bedrock Console Model Catalog](https://console.aws.amazon.com/bedrock/home?region=us-west-2#/model-catalog) and that your AWS IAM role has permission to run the model from Bedrock.

The startup is the same as described in the Quick Start above, but before you run setup or more importantly `claude``, you should set the following environment variables in the shell that you are going to run claude.

You can lookup the id for different bedrock ANTHROPIC_MODEL IDs by going the the AWS Bedrock Console and click on [Cross-region inference](https://console.aws.amazon.com/bedrock/home?region=us-west-2#/inference-profiles) under `Infer` in the left Navbar of the Amazon Bedrock console page. Note that it must start with `us.` or `global.` to be an Inference profile.

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=<aws region you are using>
export ANTHROPIC_MODEL=us.anthropic.claude-sonnet-4-5-20250929-v1:0
export AWS_PROFILE=<your aws profile from ~/.aws/config>
```

Then run `claude` as described in the quickstart.

#### Working with AWS SSO

If you are using AWS SSO, you should sso in before you run `claude`.
You will also need to get the temporary credentials generated for the SSO session and copy them into your credentials setup in System Initiative.

```bash
aws sso login
aws configure export-credentials --profile <the aws profile from ~/.aws/config>
```

The output of the last command will show you the temporary Key ID, Secret Key and Session token that you can then copy into the System Initiative MyCredentials configuration.

### Need help?

- **Discord:** Join our community for quick questions and help. _(Click the Discord button at the top of this README)_
- **Email:** [support@systeminit.com](mailto:support@systeminit.com)

### Contributing

We love contributions—ideas, docs, bug reports, and code! If you’ve got feedback or fixes, you’re in the right place.

**Ways to help**

- Try the quick start and tell us what’s confusing—open an issue here.
- Improve the docs or setup experience—PRs welcome in this repo.
- Share ideas for new capabilities or rough edges you hit.

**Where code changes go**

- The MCP **server code** lives in the System Initiative monorepo:
  - https://github.com/systeminit/si/tree/main/bin/si-mcp-server
    If your change affects the server’s behavior/APIs/tools, please open a PR there.
- This repo contains the **Docker packaging and installer**. Changes to the `Dockerfile`, `setup.sh`, `CLAUDE.md` or this README should come **here**.

Not sure where something belongs? Open an issue in this repo and we’ll help route it.

### Security

- Treat your **workspace token** like a secret. Do not commit it, paste it in issues, or share it.
- If you suspect compromise, rotate the token in System Initiative and re-run `./setup.sh` with the new token.

### License

See **LICENSE** in this repository.

### FAQ

**Q:** **Does the script support non-interactive installs?**
**A:** Yes—export `SI_WORKSPACE_TOKEN` before running `./setup.sh`.

**Q:** **Can I run multiple agents against different workspaces?**
**A:** Yes. Each agent is 1:1 with a single workspace. **Recommended:** use a **separate repo checkout per workspace** and run `./setup.sh` in each folder with that workspace's token.

**Q:** **Which OSes are supported?**
**A:** macOS, Linux, and Windows via WSL2.

### Troubleshooting

**`permission denied: ./setup.sh`**

- Make it executable: `chmod +x setup.sh`

**`docker: command not found` or Docker not running**

- Install Docker Desktop (macOS/Windows) or Docker Engine (Linux) and ensure the daemon is running.

**Token issues**

- Double-check that your **System Initiative Workspace Token** is valid and not expired. Re-export it and re-run `./setup.sh`.

**Port/conflict issues**

- If another local service conflicts, stop it or change the container’s port mapping (if the setup script supports it) and re-run the installer.
