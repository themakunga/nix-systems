# AI agents / Agentes de IA

[README](../README.md)

[English](#english) | [Español](#español)

## English

Configuration: `my.agentWiki.enable`, `my.agentWiki.autoSync.enable`.

The shared vault beneath `~/.vaults/` supplies agent instructions
and the standalone GLaDOS skill. Activation registers configured hooks for Codex,
Claude Code and Hermes, reporting `OK: GLaDOS <agent>` on success instead of full JSON.
Hook registration and voice authorization are separate; existing runtime permissions
still apply. Optional vault synchronization defaults to a 300-second interval.

### Codex installation and journal permissions

Import `applicationModules.ai` once and select the required tools independently:

```nix
my.apps = {
  codex.enable = true;
  claude-code.enable = true;
  opencode.enable = true;
  gemini-cli.enable = true;
  llama = {
    enable = true;
    server.enable = true;
    host = "127.0.0.1";
    port = 8080;
    maxModels = 1;
    extraArgs = ["--cache-type-k" "q8_0" "--cache-type-v" "q8_0"];
  };
};
```

`my.apps.llama.package` selects the llama.cpp build. `server.enable` declares a
launchd user agent on macOS or a systemd user service on Linux; enabling the
package alone does not start a server. Router parameters stay under
`my.apps.llama`. Model presets, OpenCode configuration, Gemini's settings template
and CLI scripts live in `public-dotfiles/local-ai`; Stow maps its hidden paths
into the user's home. Gemini's template is copied only when settings are absent.
OpenCode uses shared SOUL/JOURNAL instructions and portable skill discovery.
Runtime authentication, Codex settings and existing Gemini settings remain private.
An optional `my.apps.gemini-cli.apiKeyFile` reads an existing private runtime file;
it never embeds a credential in the Nix store. Aperture retains its existing
separate credential provisioning. Kanagawa enables all five tools; Outer Heaven
and Aperture retain Codex, Claude Code and Gemini without a new local model service.

Install Codex through `applicationModules.ai` and `my.apps.codex.enable`,
including when adding another coding host. The module installs Codex and its
journal prerequisites and enables the shared amgmt integration. Activation links
`~/.codex/AGENTS.md` to `~/.vaults/amgmt/agents/SOUL.md` for the primary user and
each configured `my.agentWiki.additionalUsers` entry. The private vault must be
accessible through that user's configured Git credentials.

Publish the amgmt `stow/codex` package before activating this Nix revision.
Activation runs Stow with `--no-folding` to link its journal command and separate
`~/.codex/rules/journal.rules`; existing `default.rules`, authentication and
Codex settings remain user-owned. Conflicting files stop Stow instead of being
adopted or overwritten. Start a new Codex session to load the global rule.

Run `journal-maintenance` by command name from any working directory, following
the installed journal skill and amgmt instructions. Its rule authorizes only
routine journal operations, including their Git subprocesses. Other commands
retain their existing approval policy; managed restrictions still apply.

### Shared skills and journal for every runtime

`applicationModules.ai` imports the shared workspace setup automatically. It
covers the primary and additional agent users on both Macs and Aperture, including
Aperture's existing glados/zeroclaw and legacy hermes service accounts. The setup
runs after the shared vault and public dotfiles are ready. It reuses the pinned
portable skill catalog, ub-mode, the local capability skills and the shared
GLaDOS/journal skills. Each native skill directory links to `~/.agents/skills`.
Existing canonical overrides win; conflicting runtime copies are preserved in
`~/.local/state/agent-workspace/backups`. Runtime built-ins and connector access
remain native and are not made portable by copying instructions.

Every runtime uses the same journal upstream beneath its user's `~/.vaults/`.
The setup validates an existing selected repository, preserves tracked/shared
configuration and writes host paths and all seven agent names into the runtime's
local `~/.config/obsidian-journal/config.toml`. New configurations use the
installed obsidian-journal skill's own template. The shared dispatcher and SOUL
links are installed for every user; the mandatory workflow is documented in
`public-dotfiles/agent/WORKSPACE.md`. Credentials and refreshed settings remain
private. Missing repository access stops setup instead of creating another vault.

OpenCode defaults to `local/auto`. The native router classifies the task and
reported context, then tries eligible local Qwen models before the current user's
configured `openai/gpt-6.1-sol` connection. The native retry hook changes models
without replaying tools or starting another session. Manual model choices bypass
routing. Availability fallback cannot identify a plausible but incorrect answer.
Coder/reasoning use 131,072-token YaRN 4 contexts; fast uses 65,536 with YaRN 2,
and flash retains 32,768. KV caches are quantized and the router loads one model.
Actual memory use and model quality require inference checks on the target host.

Validation without activation:

```sh
nix eval --impure --json --file scripts/check-aperture-workspace.nix
python3 scripts/check-agent-workspace.py /path/to/public-dotfiles
python3 /path/to/public-dotfiles/agent/test_shared_workspace.py
node --test /path/to/public-dotfiles/local-ai/tests/router.test.mjs
python3 /path/to/public-dotfiles/local-ai/tests/native-router.py
```

### Aperture Science

The host bundle imports `applicationModules.ai`, `coding-agents`, `github-cli` and
`hermes`. Wheatley and Nicolas receive Codex, Claude Code, Gemini CLI and native
Hermes, plus btop, htop, glab, newsboat and glow. The `ub-mode` application module installs
the pinned skill for the interactive agents and the Crapper, Dryer, Mutator and
UML Viewer commands. Existing skill installations are preserved. UML Viewer's
pinned Maven dependencies populate the user cache on first run; its upstream
Grok/Terminal.app GUI integration is not verified on Linux. ZeroClaw retains its dedicated
GLaDOS account and local Ollama service.

GitHub and Codex credentials are encrypted in the private secrets repository with
Aperture and administrator recipients, excluding CI. Runtime SOPS files are
readable only by root and the interactive users' private group. Codex authentication
is seeded into each user's writable `~/.codex/auth.json` with mode 0600; later
activations preserve refreshed credentials. A copied OAuth session can require
fresh per-host login after server-side expiration or refresh-token rotation. Gemini and Hermes use the existing
Gemini secret through a private runtime environment.

Each interactive user receives a separate `~/.vaults/amgmt` checkout over HTTPS.
The Git credential helper reads the runtime token; no token is placed in the Git
URL or repository configuration. GitHub CLI settings are seeded from
`public-dotfiles/gh/config.aperture-science.yml` into `~/.config/gh/config.yml`,
using HTTPS and the system Git credential helper. Public Hermes settings come from
`public-dotfiles/hermes/config.aperture-science.yaml` and are seeded into
`~/.hermes/config.yaml`. Claude Code still requires its own account login.

After publication, merge the public configuration through `develop` to `main`
before the owner activates the Nix change. A fresh login applies new group
membership and shell environment exports. Native hook trust remains a runtime
review step.

Validation without activation:

```sh
nix eval --impure --json --file scripts/check-aperture-agents.nix
python3 scripts/check-agent-auth.py
```

## Español

`my.agentWiki.enable` conecta el vault de `~/.vaults/` y sus instrucciones.
La integración de Codex, Claude Code y Hermes muestra una línea OK por agente.
Registrar hooks no concede autorización de voz. `my.agentWiki.autoSync.enable`
controla la sincronización periódica; el intervalo predeterminado es 300 segundos.
