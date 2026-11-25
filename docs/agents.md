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

### Wheatley's journal and installed skills

`applicationModules.agent-workspace` is enabled only for Aperture's primary
user, Wheatley. It supplies Lua, Taplo and jq, links 45 pinned portable skills
from the current workstation's catalog, and adds the existing journal and GLaDOS
skills from `~/.vaults/amgmt`. The separately declared ub-mode skill completes
48 user skills; Codex supplies its five bundled system skills. Native discovery
retains upstream plugin namespaces, such as `mattpocock-skills:tdd` and
`ponytail:ponytail`, while vault skills keep `obsidian-journal` and `glados`.

The journal uses the existing private repository at `~/.vaults/journal` and a
runtime-local `~/.config/obsidian-journal/config.toml`. Its installer renders the
skill's own template from `public-dotfiles/agent/journal-settings.json` and writes
`~/.obsidian-journal-vault`. The shared tracked configuration retains the other
host's path. Existing skills, journal configuration and Codex authentication are
preserved; no lifecycle hook approval or extra voice authorization is granted.

Pinned skill bodies match the installed workstation versions, including retro
and the explicit-invocation setting of code-simplification. App-specific plugin
connectors and credentials are not transferred. Installation makes skills
available in a new Codex session after owner activation.

```sh
nix eval --impure --json --file scripts/check-aperture-workspace.nix
python3 scripts/check-agent-workspace.py /path/to/public-dotfiles /path/to/obsidian-journal
```

### Aperture Science

The host bundle imports `applicationModules.coding-agents`, `github-cli` and
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
