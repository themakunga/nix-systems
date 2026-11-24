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
activations preserve refreshed credentials. Gemini and Hermes use the existing
Gemini secret through a private runtime environment.

Each interactive user receives a separate `~/.vaults/amgmt` checkout over HTTPS.
The Git credential helper reads the runtime token; no token is placed in the Git
URL or repository configuration. Public Hermes settings come from
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
